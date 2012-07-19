Dir['./lib','./lib/**'].reject{|f| !File.directory?(f)}.map{|dir| $:.unshift(dir) }
Dir['./vendor/**/*.rb','./lib/**/*.rb'].map {|f| require f}

require 'fileutils'
require 'logger'

include Jitterbug::Layers
include Jitterbug::Sketch

describe Jitterbug::Layers::Sketch do
	before(:all) do 
		@logger = Logger.new(STDOUT)
		@logger.level = Logger::DEBUG
		@logger.datetime_format = "%H:%M:%S" 
		
		@engine = Jitterbug::GraphicsEngine::Engine.new()

    @engine[:image_processor] = Jitterbug::NullGraphicsEngine::NullImage.new
    @engine[:renderer] = Jitterbug::NullGraphicsEngine::NullRenderer.new
    @engine[:scene_graph] = Jitterbug::GraphicsEngine::SceneGraph.new
    @engine[:spatial_data_partition] = Jitterbug::NullGraphicsEngine::NullSpatialDataPartition.new
    @engine[:sketch_api] = Jitterbug::GraphicsEngine::SketchAPI.new
    @engine[:culler] = Jitterbug::GraphicsEngine::Culler.new
    @engine[:camera] = Jitterbug::GraphicsEngine::Camera.new
    @engine[:frustum] = Jitterbug::GraphicsEngine::Frustum.new
    @engine[:compositor] = Jitterbug::NullGraphicsEngine::NullLayerCompositor.new
    @engine[:frame_processor] = Jitterbug::GraphicsEngine::LinearFrameProcessor.new
    @engine[:render_loop] = Jitterbug::GraphicsEngine::SingleImageRenderLoop.new                      
    
	end
	
	before(:each) do
			@test_dir = File.expand_path(File.dirname(__FILE__))
			@full_dir = File.join(@test_dir,"validation_sketch")
			FileUtils.remove_dir(@full_dir,force=true) if File.directory? @full_dir	
			@sketch_name = "validation_sketch"
			create_sketch(@sketch_name, @test_dir)	
		end
		
	after(:each) do		
		FileUtils.remove_dir(@full_dir,force=true) if File.directory? @full_dir		
	end		
		
	describe "new layer" do
		it "should create a new layer with provided name" do 
			lm = Sketch.new(@engine,{:working_dir => @full_dir,:logger=>@logger})
			lm.number_of_layers.should == 0
			name = "My Layer"
			lm.create_new_layer(name)
			lm.selected_layer.id.should == "layer_1"
			lm.number_of_layers.should == 1
		end
		
		it "should add ~count of the layer name if the layer name already exists"	do 
			lm = Sketch.new(@engine,{:working_dir => @full_dir,:logger=>@logger})
			name = "My Layer"
			id1 = lm.create_new_layer(name).selected_layer.id
			id2 = lm.create_new_layer(name).selected_layer.id
			id3 = lm.create_new_layer(name).selected_layer.id
			id4 = lm.create_new_layer(name).selected_layer.id
			
			lm.number_of_layers.should == 4
			
			id1.should == "layer_1"
			id2.should == "layer_2"
			id3.should == "layer_3"
			id4.should == "layer_4"
		end
		
		it "should create a new ruby script" do
			lm = Sketch.new(@engine,{:working_dir => @full_dir,:logger=>@logger})
			File.exists?("#{@full_dir}/scripts/my_layer").should == false
			name = "My Layer"
			id = lm.create_new_layer(name).selected_layer.id
			File.exists?("#{@full_dir}/scripts/my_layer.rb").should == true
			layer = lm.get_layer(id)
			layer.script.should == "#{@full_dir}/scripts/my_layer.rb"
		end
		
		it "should increment scripts names" do
			lm = Sketch.new(@engine,{:working_dir => @full_dir,:logger=>@logger})
			name = "My Layer"
			lm.create_new_layer(name).
			  create_new_layer(name).
			  create_new_layer(name).
			  create_new_layer(name)
			
			File.exists?("#{@full_dir}/scripts/my_layer.rb").should == true
			File.exists?("#{@full_dir}/scripts/my_layer_1.rb").should == true
			File.exists?("#{@full_dir}/scripts/my_layer_2.rb").should == true
			File.exists?("#{@full_dir}/scripts/my_layer_3.rb").should == true
		end

		it "should rename the ruby script when the layer is renamed" do
			lm = Sketch.new(@engine,{:working_dir => @full_dir,:logger=>@logger})
			name = "My Layer"
			id1 = lm.create_new_layer(name).selected_layer.id
			
			new_name = "My Renamed Layer"
			lm.rename_layer(id1, new_name)
			File.exists?("#{@full_dir}/scripts/my_renamed_layer.rb").should == true
			File.exists?("#{@full_dir}/scripts/my_layer.rb").should == false
		end
	end	
	
	describe "deleting a layer" do
		it "should remove the layer from the layers cache" do 
			lm = Sketch.new(@engine,{:working_dir => @full_dir,:logger=>@logger})	
			name = "My Layer"
			id = lm.create_new_layer(name).selected_layer.id
			lm.number_of_layers.should == 1
			lm.delete_layer(id)
			lm.number_of_layers.should == 0
		end
		
		it "should move the layer's script to the trash"	do	
			lm = Sketch.new(@engine,{:working_dir => @full_dir,:logger=>@logger})	
			name = "My Layer"
			id = lm.create_new_layer(name).selected_layer.id			
			lm.delete_layer(id)
			File.exists?("#{@full_dir}/scripts/my_layer.rb").should == false
			File.exists?("#{@full_dir}/trash/my_layer.rb").should == true
		end
		
		it "should work with both layer name and id" do 
			lm = Sketch.new(@engine,{:working_dir => @full_dir,:logger=>@logger})	
			lm.add("A")
			lm.add("B")
			id = lm.add("C").selected_layer.id
			lm.save
			lm.delete("B")
			lm.delete(id)
			lm.save
			lm.number_of_layers.should == 1
		end
	end
	
	describe "layer.yaml i/o" do
		it "should save the layer data to layer.yml" do 
			lm = Sketch.new(@engine,{:working_dir => @full_dir,:logger=>@logger})	
			name = "My Layer"
			id = lm.create_new_layer(name).selected_layer.id			
			lm.save
			
			#load the yaml file directly and verify the stuff is saved...
			require 'yaml'
			 begin
				file = File.open("#{@full_dir}/layers.yml")
				parsed = YAML.load(file)
				file.close
			rescue ArgumentError => e			
				fail("Could not parse layer.yaml: #{e.message}")
			end
			parsed.layer_counter.should == 1
			parsed.layers['layer_1'].name.should == name			
			parsed.layers['layer_1'].id.should == 'layer_1'
			parsed.layers['layer_1'].order.should == 1
			parsed.layers['layer_1'].active.should == true
			parsed.layers['layer_1'].visible.should == true
			parsed.layers['layer_1'].script.should == "#{@full_dir}/scripts/my_layer.rb"
			#:id,:visible, :order, :script, :active, :name
		end
		
		it "should load the layer data from layer.yml" do
			lm = Sketch.new(@engine,{:working_dir => @full_dir,:logger=>@logger})	
			name = "My Layer"
			id = lm.create_new_layer(name).selected_layer.id	
			
			lm.save
			
			lm2 = Sketch.new(@engine,{:working_dir => @full_dir,:logger=>@logger})
			lm2.load
			
			lm2.number_of_layers.should == 1
			lm2.get_layer('layer_1').name.should == name			
			lm2.get_layer('layer_1').id.should == 'layer_1'
			lm2.get_layer('layer_1').order.should == 1
			lm2.get_layer('layer_1').active.should == true
			lm2.get_layer('layer_1').visible.should == true
			lm2.get_layer('layer_1').script.should == "#{@full_dir}/scripts/my_layer.rb"
		end
		
		it "should back up an existing layer.yml before doing a save" do 
			lm = Sketch.new(@engine,{:working_dir => @full_dir,:logger=>@logger})				
			lm.create_new_layer("My Layer")				
			lm.save
			
			File.exists?("#{@full_dir}/layer.yml.bak").should == true
			lm.create_new_layer("Another Layer")
			lm.save
			File.exists?("#{@full_dir}/layer.yml.bak").should == true
		end
		
		it "should be able to restore the layer.yml from the backup" do
			lm = Sketch.new(@engine,{:working_dir => @full_dir,:logger=>@logger})				
			lm.create_new_layer("My Layer")				
			lm.save #create backup of empty layer.yml
			lm.create_new_layer("Another Layer")
			lm.number_of_layers.should == 2	
			lm.save #create backup of only one layer
			
			lm.revert #should load from backup and save to layer.yml
			lm.number_of_layers.should == 1			
		end
		
		it "should swap the layer.yml with layer.yml.bak when doing a restore" do
		  lm = Sketch.new(@engine,{:working_dir => @full_dir,:logger=>@logger})				
			lm.create_new_layer("My Layer")				
			lm.save #create backup of empty layer.yml
			lm.create_new_layer("Another Layer")
			lm.number_of_layers.should == 2	
			lm.save #create backup of only one layer
			
			lm.revert #at this point, the 2 layers should be the backup
			lm.number_of_layers.should == 1		
			
			#revert again, should get the 2 layers back
			lm.revert
			lm.number_of_layers.should == 2
			
			lm.revert
			lm.number_of_layers.should == 1		
	  end	  
	end
	
	describe "select" do 		
		it "should de-activate all other layers" do
			lm = Sketch.new(@engine,{:working_dir => @full_dir,:logger=>@logger})	
			id1 = lm.create_new_layer("A")
			id2 = lm.create_new_layer("B")
			id3 = lm.create_new_layer("C")
			id4 = lm.create_new_layer("D")
			
			lm.get_layer("layer_1").active.should == false
			lm.get_layer("layer_2").active.should == false
			lm.get_layer("layer_3").active.should == false
			lm.get_layer("layer_4").active.should == true
			
			lm.layers{|layer| layer.active = true}
			
			lm.select("layer_1")
			lm.get_layer("layer_1").active.should == true
			lm.get_layer("layer_2").active.should == false
			lm.get_layer("layer_3").active.should == false
			lm.get_layer("layer_4").active.should == false
			
		end
		
		it "should make the specified layer active" do 
			lm = Sketch.new(@engine,{:working_dir => @full_dir,:logger=>@logger})	
			id1 = lm.create_new_layer("A").selected_layer.id	
			id2 = lm.create_new_layer("B").selected_layer.id	
			id3 = lm.create_new_layer("C").selected_layer.id	
			id4 = lm.create_new_layer("D").selected_layer.id	
			
			lm.select(id1)
			lm.get_layer(id1).active.should == true
			
			lm.select(id2)
			lm.get_layer(id2).active.should == true
			
			lm.select(id3 )
			lm.get_layer(id3 ).active.should == true
			
			lm.select(id4)
			lm.get_layer(id4).active.should == true
		end
		
		it "should accept layer id" do
			lm = Sketch.new(@engine,{:working_dir => @full_dir,:logger=>@logger})	
			id1 = lm.create_new_layer("A").selected_layer.id		
			lm.select(id1)
			lm.get_layer(id1).active.should == true
		end
		
		it "should accept layer name" do
			lm = Sketch.new(@engine,{:working_dir => @full_dir,:logger=>@logger})	
			id1 = lm.create_new_layer("A").selected_layer.id		
			lm.create_new_layer("B").
			  create_new_layer("C").
			  create_new_layer("D")
			
			lm.select("A")
			lm.get_layer(id1).active.should == true
		end
		
	end
	
	describe "move" do
		it "should decrease the order of a selected layer when moving up" do
			lm = Sketch.new(@engine,{:working_dir => @full_dir,:logger=>@logger})	
			id1 = lm.create_new_layer("A").selected_layer.id		
			id2 = lm.create_new_layer("B").selected_layer.id	
			id3 = lm.create_new_layer("C").selected_layer.id	
			id4 = lm.create_new_layer("D").selected_layer.id	
			
			lm.get_layer(id1).order.should == 1
			lm.get_layer(id2).order.should == 2
			lm.get_layer(id3).order.should == 3
			lm.get_layer(id4).order.should == 4
			
			lm.select(id3)
			lm.move_closer
			
			lm.get_layer(id1).order.should == 1
			lm.get_layer(id2).order.should == 3
			lm.get_layer(id3).order.should == 2
			lm.get_layer(id4).order.should == 4
			
			lm.move_closer
			
			lm.get_layer(id1).order.should == 2
			lm.get_layer(id2).order.should == 3
			lm.get_layer(id3).order.should == 1
			lm.get_layer(id4).order.should == 4
		end
		
		
		it "should move a selected layer down"		do
			lm = Sketch.new(@engine,{:working_dir => @full_dir,:logger=>@logger})	
			id1 = lm.create_new_layer("A").selected_layer.id		
			id2 = lm.create_new_layer("B").selected_layer.id	
			id3 = lm.create_new_layer("C").selected_layer.id	
			id4 = lm.create_new_layer("D").selected_layer.id		
			
			lm.get_layer(id1).order.should == 1
			lm.get_layer(id2).order.should == 2
			lm.get_layer(id3).order.should == 3
			lm.get_layer(id4).order.should == 4
			
			lm.select(id1)
			lm.move_farther_away
			
			lm.get_layer(id1).order.should == 2
			lm.get_layer(id2).order.should == 1
			lm.get_layer(id3).order.should == 3
			lm.get_layer(id4).order.should == 4
		
			lm.move_farther_away
			
			lm.get_layer(id1).order.should == 3
			lm.get_layer(id2).order.should == 1
			lm.get_layer(id3).order.should == 2
			lm.get_layer(id4).order.should == 4
			
			lm.move_farther_away
			
			lm.get_layer(id1).order.should == 4
			lm.get_layer(id2).order.should == 1
			lm.get_layer(id3).order.should == 2
			lm.get_layer(id4).order.should == 3
			
			lm.move_farther_away
			
			lm.get_layer(id1).order.should == 4
			lm.get_layer(id2).order.should == 1
			lm.get_layer(id3).order.should == 2
			lm.get_layer(id4).order.should == 3
		end		
	end
		
	describe "clean" do
		it "should empty the trash bin" do
			lm = Sketch.new(@engine,{:working_dir => @full_dir,:logger=>@logger})	
			id1 = lm.create_new_layer("A").selected_layer.id		
			id2 = lm.create_new_layer("B").selected_layer.id	
			lm.save
			lm.delete(id1)
			lm.delete(id2)
			
			File.exists?("#{@full_dir}/trash/a.rb").should == true
			File.exists?("#{@full_dir}/trash/b.rb").should == true
			
			lm.clean(:trash)
			
			File.exists?("#{@full_dir}/trash/a.rb").should == false
			File.exists?("#{@full_dir}/trash/b.rb").should == false
		end

		it "should empty output dir" do
		  lm = Sketch.new(@engine,{:working_dir => @full_dir,:logger=>@logger})	
			id1 = lm.create_new_layer("A").selected_layer.id		
			id2 = lm.create_new_layer("B").selected_layer.id	
			lm.save
			
			#since I'm not rendering anything yet, create a file to prove that the entire dir is emptied on clean
      FileUtils.mkdir_p("#{@full_dir}/output/test/data")
      File.exists?("#{@full_dir}/output/test/data").should == true
      
      lm.clean(:output)
      File.exists?("#{@full_dir}/output/test/data").should == false
	  end
		
		it "should empty the log dir" do
		  mock_bootstrap = double("BootStrap")	
		  mock_bootstrap.stub :create_graphics_renderer
      mock_bootstrap.stub :process_layers
      mock_bootstrap.stub :load_shaders
      mock_bootstrap.stub :load_textures
      mock_bootstrap.stub :load_models
      mock_bootstrap.stub :load_audio
      mock_bootstrap.stub :load_video
      mock_bootstrap.stub :render
		  	   
		  mock_env = double("RenderEnv")
		  mock_env.stub(:bootstrap).and_return(mock_bootstrap)		  
		  
		  lm = Sketch.new(@engine,{:working_dir => @full_dir,:logger=>@logger, :env=>mock_env})	
			id1 = lm.create_new_layer("A")	
			id2 = lm.create_new_layer("B")
			lm.save
			lm.render
			File.exists?("#{@full_dir}/logs/render.log").should == true
			lm.clean(:logs)
			File.exists?("#{@full_dir}/logs/render.log").should == false
	  end	  
	  
	  it "should empty all" do
	    lm = Sketch.new(@engine,{:working_dir => @full_dir,:logger=>@logger})	
			id1 = lm.create_new_layer("A").selected_layer.id		
			id2 = lm.create_new_layer("B").selected_layer.id	
			lm.save
			
			lm.delete(id1)
			lm.delete(id2)
			
			File.exists?("#{@full_dir}/trash/a.rb").should == true
			File.exists?("#{@full_dir}/trash/b.rb").should == true
			
			#since I'm not rendering anything yet, create a file to prove that the entire dir is emptied on clean
      FileUtils.mkdir_p("#{@full_dir}/output/test/data")
      File.exists?("#{@full_dir}/output/test/data").should == true
      
      lm.render
			File.exists?("#{@full_dir}/logs/render.log").should == true
			
      lm.clean(:all)
      File.exists?("#{@full_dir}/output/test/data").should == false
			File.exists?("#{@full_dir}/logs/render.log").should == false    
			File.exists?("#{@full_dir}/trash/a.rb").should == false
			File.exists?("#{@full_dir}/trash/b.rb").should == false  
    end
	end
	
	describe "clone" do
		it "should copy layer to the foreground" do 		  
			lm = Sketch.new(@engine,{:working_dir => @full_dir,:logger=>@logger})	
			id1 = lm.create_new_layer("A")	
			id2 = lm.create_new_layer("B")
			lm.save
			lm.copy("A")
			cloned_layer = lm.get_layer("layer_3")
			cloned_layer.order.should == 3
		end
				
		it "should select the new layer" do 
		  lm = Sketch.new(@engine,{:working_dir => @full_dir,:logger=>@logger})	
			id1 = lm.create_new_layer("A")	
			id2 = lm.create_new_layer("B")
			lm.save
			lm.copy("A")
			cloned_layer = lm.get_layer("layer_3")
			cloned_layer.active.should == true
	  end
	  
		it "should name the new layer" do
		  lm = Sketch.new(@engine,{:working_dir => @full_dir,:logger=>@logger})	
			id1 = lm.create_new_layer("A")	
			id2 = lm.create_new_layer("B")
			lm.save
			lm.copy("A","C")
			cloned_layer = lm.get_layer("layer_3")
			cloned_layer.name.should == "C"
	  end
	end
	
end