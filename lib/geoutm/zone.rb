class Zone
  
  @@special_zone_offsets = {"32V" => 6}
  
  def self.longorigin(zn, zl)
    special_zone_offset = @@special_zone_offsets["#{zn}#{zl}"] || 0
    longorigin = (zn - 1) * 6 - 180 + 3 + special_zone_offset
  end
  
end