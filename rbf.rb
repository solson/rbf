#!/usr/bin/env ruby

module Brainfuck
  class Program
    def initialize(source)
      @source = source.to_s
      @loop_starts = {}
      @loop_ends = {}

      # match loops [ and ] and store their locations
      loop_starts = []
      @source.chars.each_with_index do |c, i|
        case c
        when '[' then loop_starts << i
        when ']'
          raise 'unmatched ] in program' if loop_starts.empty?
          start = loop_starts.pop
          @loop_ends[start] = i
          @loop_starts[i] = start
        end
      end

      raise 'unmatched [ in program' unless loop_starts.empty?
    end

    def run!
      data = [0]
      dp = 0
      ip = 0

      while ip < @source.length do
        c = @source[ip]

        case c
        when '+' then data[dp] += 1
        when '-' then data[dp] -= 1
        when '>'
          dp += 1
          data[dp] ||= 0
        when '<'
          raise 'attempt to decrement data pointer below zero' if dp == 0
          dp -= 1
        when '.' then putc data[dp]
        when ',' then data[dp] = $stdin.getbyte
        when '[' then ip = @loop_ends[ip] if data[dp] == 0
        when ']' then ip = @loop_starts[ip] - 1
        when '#' then p data, dp
        end

        ip += 1
      end
    end
  end
end

Brainfuck::Program.new(ARGV[0]).run! if ARGV[0]
