#!/usr/bin/env ruby
#

###
#
# (c) 2009-2013, Copyright, Bjoern Rennhak, The University of Tokyo
#
# @file       boxcar.rb
# @author     Bjoern Rennhak
#
#######


# @class      Class Boxcar
# @brief      The class Boxcar takes input data an applies a Boxcar Impulse Response FIlter on it.
class Boxcar

  # @fn       def initialize  # {{{
  # @brief    Custom constructor for the Boxcar class
  def initialize
  end # of def initialize }}}

  # @fn       def box_car_filter input, order = 5 # {{{
  # @brief    In order to extract meaningful information easily we utilize a box car or FIR filter known from DSP theory.
  #
  # @param    input   Array containing beat [ [ time, energy value ], ...]
  # @param    order   N is the filter order; an Nth-order filter has (N + 1) terms on the right-hand
  #                   side. The x[n − i] in these terms are commonly referred to as taps, based on the structure of a
  #                   tapped delay line that in many implementations or block diagrams provides the delayed inputs to
  #                   the multiplication operations. One may speak of a "5th order/6-tap filter", for instance.
  #
  # @info     http://en.wikipedia.org/wiki/Finite_impulse_response
  #           htttp://groups.google.com/group/comp.dsp/msg/d0d2324de8451878  
  #
  # @returns  Array, containing time t and beat energy e box car'ed. [ [t0,e0], [t1,e1], ... ]
  def box_car_filter input = nil, order = 5

    # Input verification {{{
    raise ArgumentError, "Input cannot be nil" if( input.nil? )
    raise ArgumentError, "Order cannot be nil" if( order.nil? )
    # }}}

    # y[n] = \sum_{i=0}^{N} b_i x[n - i]
    #  - x[n] is the input signal,
    #  - y[n] is the output signal,
    #  - bi are the filter coefficients, also known as tap weights, that make up the impulse response,
    #  - N is the filter order; an Nth-order filter has (N + 1) terms on the right-hand side.

    y = []

    # split time and energy
    x = input.collect { |a,b| b }

    cnt = 0

    while( not x.empty? )
      
      # take adjacent samples
      old_chunk = x.shift( order )
      chunk     = old_chunk.dup

      # compute average
      average = ( chunk.inject(0) { |b,i| b+i } ) / ( chunk.length )
  
      # push result to array
      y[ cnt ] = average
      cnt += 1
  
      # throw away one sample and repeat
      old_chunk.shift
      x = old_chunk.concat( x )
    end # of while

    # recombine time and FIR result into array of subarrays
    result = ( input.collect { |a,b| a } ).zip( y )
    result

#    0.upto( x.length - 1 ) do |n|
#
#      sum = 0
#      0.upto( order ) do |i|
#
#        # moving average filter (boxcar)
#        b = 1 / ( i + 1 )
#
#        sum += ( b * x[n - i] ) unless( 0 < (n - i) )
#
#      end # of 0.upto( order ) do |i|
#
#      y[ n ] = sum
#    end # of 0.upto( x.length ) do |n|
#
#    # recombine time and FIR result into array of subarrays
#    result = ( input.collect { |a,b| a } ).zip( y )
#    result
  end # of def box_car_filter }}}

end


# Direct Invocation (local testing) # {{{
if __FILE__ == $0
end # of if __FILE__ == $0 }}}

# vim:ts=2:tw=100:wm=100
