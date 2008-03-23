#!/usr/bin/ruby

message_hash = Hash::new

src_strings_file = open($*[0])
src_strings_file.each { |line|

  if  /\/\* Class = ".*"; .* = "(.*)"; ObjectID = ".*"; \*\// =~ line
    message_hash.store($1, $1)
  end
}
src_strings_file.close

message_hash.each_key { |key|
  printf "%s=%s\n", key, key
}
