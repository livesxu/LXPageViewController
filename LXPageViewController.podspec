
Pod::Spec.new do |s|

  s.name         = "LXPageViewController"
  s.version      = "0.1.0"
  s.summary      = "LXPageViewController"
  s.homepage     = "https://github.com/livesxu/LXPageViewController.git"
  s.license      = "MIT"
  s.author       = { "livesxu" => "livesxu@163.com" }
  s.platform     = :ios, "5.0"
  s.source       = { :git => "https://github.com/livesxu/LXPageViewController.git", :tag => s.version }
  s.source_files  = "LXPageViewController"
  s.frameworks    = 'UIKit'
  s.requires_arc  = true

end