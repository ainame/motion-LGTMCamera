class AssetManager
  def self.sharedInstance
    Disptach.once { @instance ||= new }
    @instance
  end

  def initialize
    @library = ALAssetLibrary.alloc.init
    @assets = []
  end

  def assets(&block)
    Dispatch::Queue.concurrent.async do
      retrieve_assets(&block)
    end
  end

  def retrieve_assets(&block)
    unless @assets.empty?
      Dispatch::Queue.main.async do
        block(@asstes, nil)
      end
      return
    end

    refresh_assets(&block)
  end

  def refresh_assets(&block)
    @library.enumerateGroupsWithTypes(
      ALAssetsGroupSavedPhotos, usingBlock: proc { |group, stop|
        group.enumerateAssetsUsingBlock do |asset, stop|
          @assets << asset if asset
          if stop
            Dispatch::Queue.main.async do
              block(@assets, nil)
            end
          end
        end
      }, failureBlock: proc {})
  end

  def save(image, &block)
    @library.writeImageToSavedPhotosAlbum(@image.CGImage, metadata:nil, completedBlock: block)
  end
end
