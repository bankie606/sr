module Sr
  VERSION = "0.0.1"
  UUID = begin `uuidgen`.strip rescue rand(10000) end
end
