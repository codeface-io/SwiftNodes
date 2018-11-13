 Pod::Spec.new do |s|
    
    # meta infos
    s.name             = "SwiftNodes"
    s.version          = "0.0.1"
    s.summary          = "Graph Algorithms & DataStructures in Swift"
    s.description      = "Graphs & Trees: Data Structures, Algorithms, Drawing"
    s.homepage         = "http://flowtoolz.com"
    s.license          = 'MIT'
    s.author           = { "Flowtoolz" => "contact@flowtoolz.com" }
    s.source           = {  :git => "https://github.com/flowtoolz/SwiftNodes.git",
                            :tag => s.version.to_s }
    
    # compiler requirements
    s.requires_arc = true
    s.swift_version = '4.2'
    
    # minimum platform SDKs
    s.platforms = {:ios => "9.0", :osx => "10.11", :tvos => "9.0"}

    # minimum deployment targets
    s.ios.deployment_target  = '9.0'
    s.osx.deployment_target = '10.11'
    s.tvos.deployment_target = '9.0'

    # sorces
    s.source_files = 'Code/**/*.swift'
end
