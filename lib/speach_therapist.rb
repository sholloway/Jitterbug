module Jitterbug
  module Speach
    class Therapist
      def initialize()
        #Try to use Karen's voice. If they don't have it default to the default.
      end
      
      def say(msg)
        %x{say #{msg}}
      end
    end
  end
end