#!/usr/bin/env ruby

xibs = [ 'MainMenu', 'Welcome', 'TwitterStatusView', 'ErrorMessageView', 'MessageTableView', ]
langs = [ { :short => 'ja', :long => 'Japanese', }, { :short => 'de', :long => 'German', }, { :short => 'es', :long => 'Spanish', } ]

xibs.each do |xib|
<<`EOS`  
/Developer/usr/bin/ibtool --generate-stringsfile English.lproj/#{xib}.xib.strings English.lproj/#{xib}.xib
nkf --unix --utf8 --overwrite English.lproj/#{xib}.xib.strings
EOS
end

xibs.each do |xib|
  langs.each do |lang|
    strings_source_file = "strings.#{lang[:short]}.txt"
    xib_strings_file = "#{xib}.xib.strings"

    STDERR.puts("processing #{strings_source_file} - #{xib_strings_file}")
<<`EOS`
etc/updateStringsByMessageTable.rb etc/#{strings_source_file} English.lproj/#{xib_strings_file} > #{lang[:long]}.lproj/#{xib_strings_file}
/Developer/usr/bin/ibtool --write #{lang[:long]}.lproj/#{xib}.xib -d #{lang[:long]}.lproj/#{xib_strings_file} English.lproj/#{xib}.xib
EOS
  end
end

