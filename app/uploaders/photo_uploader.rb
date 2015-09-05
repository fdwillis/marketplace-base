class PhotoUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def extension_white_list
     %w(jpg jpeg gif png)
  end

 version :p150x150 do
   process :resize_and_pad => [150,150]
 end
 # version :p200x200 do
 #   process :resize_and_pad => [200,200]
 # end
 version :p400x400 do
   process :resize_and_pad => [400,400]
 end
 # version :p540x160 do
 #   process :resize_to_fit => [540, 160]
 #   #process :resize_and_pad => [540,160]
 # end
 # version :p530x150 do
 #   process :resize_and_pad => [530,150]
 # end
 version :p500x350 do
   process :resize_and_pad => [500,350]
 end

end