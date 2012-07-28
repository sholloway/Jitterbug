require 'delegate'
require 'engine_parts'

module Jitterbug 
  module GraphicsEngine 
    class Engine < DelegateClass(Hash)      
      Pieces = [:renderer,:scene_graph,:spatial_data_partition,:sketch_api,:culler,:camera,:frustum,:compositor,:frame_processor,:render_loop, :image_processor]
      
      EngineMap = {:renderer => Jitterbug::GraphicsEngine::Renderer,
        :scene_graph => Jitterbug::GraphicsEngine::SceneGraph,
        :spatial_data_partition => Jitterbug::GraphicsEngine::SpatialDataPartition,
        :sketch_api => Jitterbug::GraphicsEngine::SketchAPI,
        :culler => Jitterbug::GraphicsEngine::Culler,
        :camera => Jitterbug::GraphicsEngine::Camera,
        :frustum => Jitterbug::GraphicsEngine::Frustum,
        :compositor => Jitterbug::GraphicsEngine::LayerCompositor,
        :frame_processor => Jitterbug::GraphicsEngine::FrameProcessor,
        :render_loop => Jitterbug::GraphicsEngine::RenderLoop,
        :image_processor => Jitterbug::GraphicsEngine::Image
        }

      def initialize
        super({})
      end
      
      def Engine.from_hash(input = {})
        engine = Engine.new
        engine.merge!(input)
        return engine
      end
      
      def bind_sketch(sketch)
        self.each_value do |part| 
          part.layers = sketch.layers
          part.logger = sketch.logger
          part.engine = self 
          part.sketch_options = sketch.options
        end
      end
      
      def unbind
        self.each_value do |part| 
          part.layers = ''
          part.logger = ''
          part.engine = ''
          part.sketch_options = ''
        end
      end

      #should only take symbols
      def []=(k,v)
        validate(k,v)
        __getobj__[k] = v
      end

      #some madness to make obj-c happy with handling symbols.
      def fetch(key)
        sym = key.to_sym
        return __getobj__[sym]       
      end

      #returns true if the Engine has be fully constructed
      def assembled?        
         (self.keys.empty?)? false : (Pieces - self.keys).size == 0
      end

      def missing_pieces
        Pieces - self.keys
      end
      
      def render
         self[:render_loop].run_loop()  
      end

      private
      def validate(key,value)
        raise Exception.new("An engine piece cannot be set to nil.") if value.nil?  
        raise Exception.new("The engine piece #{key} is not valid.\nThe only valid engine pieces are are:\n#{Pieces}") unless Pieces.include?(key)        
        raise Exception.new("The engine piece #{value.to_s} is not valid.\nA #{key} must be a descendent of #{EngineMap[key]}") unless value.class.ancestors.include?(EngineMap[key])
      end
    end
  end
end