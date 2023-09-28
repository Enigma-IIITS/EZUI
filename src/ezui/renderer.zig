const std = @import("std");
const gpu = @import("mach-gpu");
const glfw = @import("mach-glfw");
const util = @import("../util.zig");

const SwapChainFormat = gpu.Texture.Format.bgra8_unorm;

pub const Renderer = struct {
    device: *gpu.Device,
    queue: *gpu.Queue,
    pipeline: *gpu.RenderPipeline,
    swapchain: *gpu.SwapChain,
    swapchain_desc: gpu.SwapChain.Descriptor,
    surface: *gpu.Surface,

    pub fn init(window: glfw.Window) Renderer {
        gpu.Impl.init();
        const instance = gpu.createInstance(null);
        if (instance == null) {
            std.log.err("Renderer, webgpu: Failed to create GPU instance\n", .{});
            std.process.exit(1);
        }

        var surface: *gpu.Surface = undefined;
        if (util.createSurfaceForWindow(instance.?, window, comptime util.detectGLFWOptions())) |surface_| {
            surface = surface_;
        } else |err| {
            std.log.err("Renderer, webgpu: Failed to create Surface, {}\n", .{err});
        }

        var response: util.RequestAdapterResponse = undefined;
        instance.?.requestAdapter(&gpu.RequestAdapterOptions{
            .compatible_surface = surface,
            .power_preference = .undefined,
            .force_fallback_adapter = .false,
        }, &response, util.requestAdapterCallback);

        if (response.status != .success) {
            std.log.err("Renderer, webgpu: Failed to create GPU adapter: {s}\n", .{response.message.?});
            std.process.exit(1);
        }

        // Print which adapter we are using.
        var props = std.mem.zeroes(gpu.Adapter.Properties);
        response.adapter.?.getProperties(&props);

        std.log.info("found {s} backend on {s} adapter: {s}, {s}\n", .{
            props.backend_type.name(),
            props.adapter_type.name(),
            props.name,
            props.driver_description,
        });

        const device = response.adapter.?.createDevice(null);
        if (device == null) {
            std.log.err("Renderer, webgpu: Failed to create GPU device\n", .{});
            std.process.exit(1);
        }

        device.?.setUncapturedErrorCallback({}, util.printUnhandledErrorCallback);

        const swapchain_desc = gpu.SwapChain.Descriptor{
            .label = "basic swap chain",
            .usage = .{ .render_attachment = true },
            .format = SwapChainFormat,
            .width = window.getSize().width,
            .height = window.getSize().height,
            .present_mode = .fifo,
        };

        const swapchain = device.?.createSwapChain(surface, &swapchain_desc);

        const vs =
            \\ @vertex fn main(
            \\     @builtin(vertex_index) VertexIndex : u32
            \\ ) -> @builtin(position) vec4<f32> {
            \\     var pos = array<vec2<f32>, 3>(
            \\         vec2<f32>( 0.0,  0.5),
            \\         vec2<f32>(-0.5, -0.5),
            \\         vec2<f32>( 0.5, -0.5)
            \\     );
            \\     return vec4<f32>(pos[VertexIndex], 0.0, 1.0);
            \\ }
        ;
        const vs_module = device.?.createShaderModuleWGSL("my vertex shader", vs);

        const fs =
            \\ @fragment fn main() -> @location(0) vec4<f32> {
            \\     return vec4<f32>(1.0, 0.0, 0.0, 1.0);
            \\ }
        ;
        const fs_module = device.?.createShaderModuleWGSL("my fragment shader", fs);

        const color_target = gpu.ColorTargetState{
            .format = SwapChainFormat,
            .write_mask = gpu.ColorWriteMaskFlags.all,
        };
        const fragment = gpu.FragmentState.init(.{
            .module = fs_module,
            .entry_point = "main",
            .targets = &.{color_target},
        });
        const pipeline_descriptor = gpu.RenderPipeline.Descriptor{
            .fragment = &fragment,
            .layout = null,
            .depth_stencil = null,
            .vertex = gpu.VertexState{
                .module = vs_module,
                .entry_point = "main",
            },
            .multisample = .{},
            .primitive = .{},
        };

        const pipeline = device.?.createRenderPipeline(&pipeline_descriptor);

        vs_module.release();
        fs_module.release();

        return Renderer{
            .device = device.?,
            .queue = device.?.getQueue(),
            .pipeline = pipeline,
            .swapchain = swapchain,
            .swapchain_desc = swapchain_desc,
            .surface = surface,
        };
    }

    pub fn resizeSwapchain(renderer: *Renderer, width: u32, height: u32) void {
        _ = renderer;
        std.log.info("hi!!!, w:{d}, h:{d}\n", .{ width, height });
        // renderer.swapchain_desc.width = width;
        // renderer.swapchain_desc.height = height;
        // renderer.swapchain.release();
        // renderer.swapchain = renderer.device.createSwapChain(renderer.surface, &renderer.swapchain_desc);
    }

    pub fn render(renderer: *Renderer) void {
        renderer.device.tick();
        const backbuffer_view = renderer.swapchain.getCurrentTextureView().?;
        const color_attachment = gpu.RenderPassColorAttachment{
            .view = backbuffer_view,
            .resolve_target = null,
            .clear_value = gpu.Color{ .r = 0.0, .g = 0.0, .b = 0.0, .a = 0.0 },
            .load_op = .clear,
            .store_op = .store,
        };
        const encoder = renderer.device.createCommandEncoder(null);
        const render_pass_info = gpu.RenderPassDescriptor.init(.{
            .color_attachments = &.{color_attachment},
        });
        const pass = encoder.beginRenderPass(&render_pass_info);
        pass.setPipeline(renderer.pipeline);
        pass.draw(3, 1, 0, 0);
        pass.end();
        pass.release();

        var command = encoder.finish(null);
        encoder.release();

        renderer.queue.submit(&[_]*gpu.CommandBuffer{command});
        command.release();
        renderer.swapchain.present();
        backbuffer_view.release();
    }

    pub fn deinit(renderer: *Renderer) void {
        _ = renderer;
    }
};
