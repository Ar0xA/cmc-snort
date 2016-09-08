Puppet::Parser::Functions::newfunction(:snort_ip_cidr, :type=> :rvalue, :doc => "find all ip addresses and netmasks and return a string in format [x.x.x.x/y, x.x.x.x/y]") do |args|
  return_string=""
  output = `/usr/sbin/ip addr show | /usr/bin/grep inet `
  output.each_line do |line|
    if ( line =~ /^*inet (\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\/\d{1,2})*/ )
      if return_string.length < 1
          return_string=line.match( /^*inet (\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\/\d{1,2})*/ )[1]
      else
          return_string=return_string+","+line.match( /^*inet (\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\/\d{1,2})*/ )[1]
      end
    end
  end
  return_string2 = "[" + return_string + "]"
end
