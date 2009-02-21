#!/usr/bin/env ruby

xibs = [ 'MainMenu', 'Welcome', 'TwitterStatusView', 'ErrorMessageView', 'MessageTableView', ]
langs = [ { :short => 'ja', :long => 'Japanese', }, { :short => 'de', :long => 'German', } ]

xibs.each do |xib|
<<`EOS`  
/Developer/usr/bin/ibtool --generate-stringsfile English.lproj/#{xib}.xib.strings English.lproj/#{xib}.xib
nkf --unix --utf8 --overwrite English.lproj/#{xib}.xib.strings
EOS
end

xibs.each do |xib|
  langs.each do |lang|
<<`EOS`
etc/updateStringsByMessageTable.rb etc/strings.#{lang[:short]}.txt English.lproj/#{xib}.xib.strings > #{lang[:long]}.lproj/#{xib}.xib.strings
/Developer/usr/bin/ibtool --write #{lang[:long]}.lproj/#{xib}.xib -d #{lang[:long]}.lproj/#{xib}.xib.strings English.lproj/#{xib}.xib
EOS
  end
end

