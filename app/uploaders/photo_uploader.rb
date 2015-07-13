class PhotoUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def extension_white_list
     %w(jpg jpeg gif png)
  end

  version :thumb do
    process :resize_to_limit => [200, 200]
  end
 version :medium do
   process :resize_and_pad => [50,50]
 end
 version :p200x200 do
   process :resize_and_pad => [200,200]
 end
 version :p531x157 do
   process :resize_and_pad => [531,157]
 end
 version :p540x160 do
   process :resize_to_fit => [540, 160]
   #process :resize_and_pad => [540,160]
 end
 version :p530x150 do
   process :resize_and_pad => [530,150]
 end
 version :p500x350 do
   process :resize_and_pad => [500,350]
 end

end