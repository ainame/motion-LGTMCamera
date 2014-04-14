class CameraViewController < UIViewController
  def viewDidLoad
    execute_camera  do |result|
      image_view = UIImageView.alloc.initWithImage(result[:original_image])
      self.view.addSubview(image_view)
    end
  end

  def execute_camera(&block)
    BW::Device.camera.rear.picture(media_types: [:movie, :image], &block)
  end
end
