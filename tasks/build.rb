EXE_VERSION = {
  'version' => {
    'file_version_number' => "#{Pik::VERSION}.0",
    'comments' => 'The Ruby version manager for Windows',
    'product_name' => 'Pik',
    'file_description' => 'Pik Runner',
    'original_filename' => 'pik_runner.exe'
  }
}

lib = FileList["lib/**/*.rb"]

file 'tools/pik_runner.exy', :needs => ['tools/pik_runner'] + lib do
  Dir.chdir 'tools' do
    sh('ruby -rexerb/mkexy pik_runner pik.bat -v')
  end
  exy = YAML.load(File.read('tools/pik_runner.exy'))
  zlib1 = {
    'file' =>  File.join(RbConfig::CONFIG['bindir'], 'zlib1.dll'),
    'type' => 'extension-library'
  }
  exy['file']['zlib1.dll']  = zlib1
  exy['resource']  = EXE_VERSION
   
  File.open('tools/pik_runner.exy', 'w+'){ |f| f.puts YAML.dump(exy) }
end

file 'tools/pik_runner.exe', :needs => ['tools/pik_runner.exy'] do
  Dir.chdir 'tools' do
    sh('ruby -S exerb pik_runner.exy')
    sh('upx --lzma pik_runner.exe') unless ENV['QUICK']
  end
end

desc "builds executable"
task :build, :needs => 'tools/pik_runner.exe'

desc "installs executable"
task :install, :needs => :build do
  sh('ruby bin/pik_install C:\\bin')
end

task :clobber_exe do
  rm_rf 'tools/pik_runner.exe'
end

task :clobber_exy, :needs => :clobber_exe do
  rm_rf 'tools/pik_runner.exy'
end

desc "rebuilds executable"
task :rebuild, :needs => [
:clobber_exy, :build]
desc "reinstalls executable"
task :reinstall, :needs => [:clobber_exy, :install]