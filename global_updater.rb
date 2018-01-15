class GlobalUpdater
  class << self
    def update_from_params(param_hash)
      params = deep_copy(param_hash)
      param_hash_each(params, "name") do |pair, path, val|
        unless pair.nil? || pair.send(path.last) == val
          pair.update_attribute(path.last, val)
        end
      end
    end

    def delete_with_params(param_hash)
      params = deep_copy(param_hash)
      param_hash_each(params, "_destroy", "1") do |pair, path, val|
        pair.destroy
      end
    end

    def rename_with_params(param_hash)
      params = deep_copy(param_hash)
      param_hash_each(params, "newname") do |response, path, val, p|
       unless response.nil? || response.pair.name == val
          response.pair.update_attribute(:name, val)
        end
      end
    end

    def add_from_params(param_hash)
      param_hash_each(param_hash, "pairs_attributes") do |section, path, val|
        newkey = val.keys.last
        if (newkey.to_i - val.keys[-2].to_i) > 1
          pair = section.first.section.pairs.create(name: val[newkey]['name'])
          pair.responses.create
        end
      end
    end

    def param_hash_each(param_hash, key, value=nil)
      loop do
        path = find_key_path(param_hash, key, value)
        break if path.empty?
        newval = remove_value(param_hash, path)

        Persona.all.each do |p|
          pair = fetch_pair_by_path(p, path)
          yield pair, path, newval, p
        end
      end
    end

    def find_key_path(target_hash, key, value=nil, path=[])
      if target_hash.keys.include?(key)
        if (value.nil? ? target_hash[key] != " " : target_hash[key] == value)
          path.push(key) and return path
        end
      end

      target_hash.each do |subkey, subval|
        if subval.is_a? Hash
          path.push(subkey)

          if find_key_path(subval, key, value, path).empty?
            path.pop
          else
            return path
          end
        end
      end

      []
    end

    def fetch_pair_by_path(persona, path)
      current = persona.sections[path.first.to_i]
      yield current, path.first if block_given?

      path[1..-1].each do |segment|
        break if current.nil?

        case segment
        when "responses_attributes"
          current = current.responses
        when "pairs_attributes"
          current = current.pairs
        when "child_sections_attributes"
          current = current.child_sections
       when /\d+/
          current = current[segment.to_i]
        else
          if current.is_a? Array
            current = current.detect {|x| x.name == segment}
          end
        end

        yield current, segment if block_given?
      end

      current
    end

    def remove_value(target_hash, path)
      return if path.empty?
      current = target_hash[path.shift]

      path[0..-2].each do |p|
        current = current[p]
      end

      rval = current[path.last]
      current[path.last] = " "
      rval
    end

    def deep_copy(source)
      Marshal.load(Marshal.dump(source))
    end
  end
end
