#!/usr/bin/ruby

message_hash = {}

message_table_file = open($*[0])
message_table_file.each { |line|
  a = line.chomp.split('=')
  message_hash.store(a[0], a[1])
}
message_table_file.close

src_strings_file = open($*[1])
src_strings_file.each { |line|
  if  /"(\d+.*)" = "(.*)";/ =~ line
    printf "\"%s\" = \"%s\";\n", $1, message_hash[$2] ? message_hash[$2] : $2
    if (!message_hash[$2] && $2 != "")
      warn "missing: " + $2
    end
  end
}
src_strings_file.close
