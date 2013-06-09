#!/usr/bin/env ruby
#

###
#
# (c) 2009-2013, Copyright, Bjoern Rennhak, The University of Tokyo
#
# @file       spline.rb
# @author     Bjoern Rennhak
#
#######


# System includes
require 'gsl'
require 'awesome_print'

# Namespaces
include GSL



# @class      Class Spline
# @brief      The class Spline takes input data an applies a spline on it
class Spline

  # @fn       def initialize  # {{{
  # @brief    Custom constructor for the Spline class
  def initialize
  end # of def initialize }}}


  # @fn       def parametrization # {{{
  # @brief    The parametrization function is used to parametrize the input data when we are dealing with
  #           multi-dimensional or non-linear data.
  #
  #           Splines must adhere to the constraint that all e.g. x_1, x_2, x_3, ... , x_n are
  #           a sequence of observations such as x_1 < x_2 < x_3 < ... < x_n.
  #
  #           In cases where this is not true we have to parametrize each input dimension by e.g. t.
  #           This can be acheved by turning x into x(t), y into y(t) and so on. This means we are
  #           treating each subspace effectively as a bi-variate function with t as its monotonic
  #           parameter.
  #
  #           A common solution for t is the variation of the cumulating distance:
  #
  #           \forall i \in [1, n]
  #
  #           t_1     = 0
  #           t_{i+1} = t_i + \sqrt{ ( x_{i+1} - x_i )^2 + ( y_{i+1} - y_i )^2 }
  #
  #           Reference: http://en.wikipedia.org/wiki/Smoothing_spline
  #                      http://www.cs.bgu.ac.il/~leonid/na105/Splines/Lee.pdf
  #
  # @param    [Array]     input       Array, containing subarrays of each data component. e.g. [ [x1,y2,..zn], [x1,y2,..zn], ..] 
  #
  # @returns  [Array]     Array containing all t values for the entire input dataset
  def parametrization input

    # We differ from the maths above that arrays start from 0 not from 1

    t = []
    t << 0

    # sometimes t values are the same, we can't have that, this will prohibit it
    # reason: malformed data?
    arbitrary = 40

    # def cumulating_distance i, t_i, tuple_now, tuple_next
    1.upto( input.length - 1 ) do |i_plus_1|

      i       = i_plus_1 - 1
      end_idx = input.length - 1

      # Check that we are not at end of list
      if( i_plus_1 <= end_idx )
        t[ i_plus_1 ] = cumulating_distance( i_plus_1, t[ i ], input[ i ], input[ i_plus_1 ] )

        # Check if t[i] == t[i_plus_1], if so, make sure there they are not the same! 
        if( t[i] == t[i_plus_1] )
          t[ i_plus_1 ] += arbitrary

          puts "(WW) [#{i.to_s}] Is your data malformed? Duplicate? This *might* cause trouble. Adjusting the parametric to be different for same point."
          puts "(WW) [#{i.to_s}] Seems that the previous t[#{i.to_s}] = #{t[i].to_s} is equal to t[#{i_plus_1.to_s}] = #{t[i_plus_1].to_s}."
          puts "(WW) [#{i.to_s}] Input[ #{i.to_s} ] = #{input[i].join(", ")}"
          puts "(WW) [#{i.to_s}] Input[ #{i_plus_1.to_s} ] = #{input[i_plus_1].join(", ")}"
        end

      else
        # There is no more i_plus_1
        t[ i_plus_1 ] = t[ i ] + arbitrary   # arbitarily move point further to make sure to satisfy monotonic condition
      end

    end

    return t
  end # }}}

  # @fn       def cumulating_distance {{{
  # @brief    Calculates the cumulating distance of n parameters based on the following
  #           function pattern. (multi-dimensional)
  #
  #           A common solution for t is the variation of the cumulating distance (2D):
  #
  #           \forall i \in [1, n]
  #
  #           t_1     = 0
  #           t_{i+1} = t_i + \sqrt{ ( x_{i+1} - x_i )^2 + ( y_{i+1} - y_i )^2 }
  #
  #           Reference: http://en.wikipedia.org/wiki/Smoothing_spline
  #                      http://www.cs.bgu.ac.il/~leonid/na105/Splines/Lee.pdf
  #
  #           e.g. tuple_now := [ x, y, z, ..]
  #
  # @param    [Numeric]     t             T is the numerical value of the cumulated distance at point t_i.
  # @paran    [Array]       tuple_now     This n-tuple contains all values of *this* iteration i
  # @paran    [Array]       tuple_next    This n-tuple contains all values of the *next* iteration i+1
  #
  # @retuns   [Numeric]     Value returned is the numerical result of cumulated distance of point t_i+1
  def cumulating_distance i, t_i, tuple_now, tuple_next

    # We differ from the maths above that arrays start from 0 not from 1

    # Rule 1: If we are at the beginning we are always 1
    return 0.0 if( i <= 0 )

    # Calculate t_{i+1}
    result  = 0.0

    # Zip tuple_now and tuple_next values at each iter together into array
    # a = [1,2,3,4,5] ; b = %w[a,b,c,d,e] ; b.zip(a) ;
    #  => [["a", 1], ["b", 2], ["c", 3], ["d", 4], ["e", 5]]
    data    = tuple_next.zip( tuple_now )

    # Substract a_{i+1} - a_{i} step
    data.collect! do |xii, xi|
      xii - xi
    end

    # Square values step
    data.collect! do |distance|
      distance ** 2
    end

    # Summation step
    result = data.inject(0) { |acc, element| acc + element } 

    # Sqrt step
    result = Math.sqrt( result )

    return t_i + result
  end # }}}

  # @fn       def clean {{{
  # @brief    Takes input data and cleans it from spaces, tabs and newlines for each line
  #
  #           " 554.2572093389093 -338.6062325459966 -561.6394251506157 \n" =>
  #           "554.2572093389093 -338.6062325459966 -561.6394251506157"
  #
  # @param    [Array]     input       Array containing each line of input data as string
  #
  # @returns  [Array]     Array containing strings without extra newlines, tabs or spaces
  def clean input
    input.collect! do |line|
      line.strip!
    end

    return input
  end # }}}

  # @fn       def extract_columns {{{
  # @brief    Takes input data and returns each column as sub-arrays.
  #           Numbers are translated from string into Numeric.
  #           "Split e.g. x(t),y(t),z(t) into their own arrays
  #
  #           "554.2572093389093 -338.6062325459966 -561.6394251506157"
  #           "714.7077358417557 -286.02874244378114 -386.06759886106306" 
  #
  #           => 
  #
  #           [ [ 554.2572093389093, 714.7077358417557 ], [ -338.6062325459966, -286.02874244378114 ], [ -561.6394251506157, -386.06759886106306 ] ]
  #           which is esseintially: [ column1, column2, column3,...]
  #
  # @param    [Array]     input       Array containing each line of input data as string
  #
  # @returns  [Array]     Array containing subarrays of each individual column
  def extract_columns input
    result = []

    # Split each line and append into subarray of result at right index
    input.each_with_index do |column_value, column_index|
      components = column_value.split( " " )
      components.collect! { |item| item.to_f }

      components.each_with_index do |row_value, row_index|
        result[ row_index ] = Array.new if( result[ row_index ].nil? )
        result[ row_index ] << row_value
      end

    end

    return result
  end # }}}

  # @fn       def extract_rows {{{
  # @brief    Takes input data and returns each row as sub-arrays with elements.
  #           Numbers are translated from string into Numeric.
  #           "Split e.g. "x(t),y(t),z(t)" into their own floats inside the array
  #
  #           "554.2572093389093 -338.6062325459966 -561.6394251506157"
  #           "714.7077358417557 -286.02874244378114 -386.06759886106306" 
  #
  #           => 
  #           [ 554.2572093389093, -338.6062325459966, -561.6394251506157 ],
  #           [ 714.7077358417557, -286.02874244378114, -386.06759886106306 ]
  #
  # @param    [Array]     input       Array containing each line of input data as string
  #
  # @returns  [Array]     Array containing subarrays of each individual row
  def extract_rows input
    result = []

    # Split each line and append into subarray of result at right index
    input.each_with_index do |column_value, column_index|
      components = column_value.split( " " )
      components.collect! { |item| item.to_f }

      result << components
    end

    return result
  end # }}}

  # @fn       def bspline_smoothing {{{
  # @brief    Takes a parameter array and data array and fits a smoothing bspline to it
  #
  # @params   [Array]     parameters      Parameters is an array containing absolute increasing numbers (x1<x2<x3...<xn)
  # @params   [Array]     data            Y axis data representing one channel of your multi-dimensional set
  def bspline_smoothing parameters, data

    n = data.length - 1
    ncoeffs = 45        # depends on the resolution you want
    nbreak = ncoeffs - 2

    GSL::Rng::env_setup()
    r = GSL::Rng.alloc()

    bw = GSL::BSpline.alloc(4, nbreak)
    b = GSL::Vector.alloc(ncoeffs)
    x = GSL::Vector.alloc(n)
    y = GSL::Vector.alloc(n)
    xx = GSL::Matrix.alloc(n, ncoeffs)
    w = GSL::Vector.alloc(n)

    for i in 0...n do
      xi = parameters[i]
      yi = data[i]
      
      sigma = 0.1
      dy = GSL::Ran.gaussian(r, sigma)
      yi += dy
      
      x[i] = xi
      y[i] = yi
      w[i] = sigma
      
    end

    bw.knots_uniform(0.0, parameters.last )

    for i in 0...n do
      xi = x[i]
      bw.eval(xi, b)
      for j in 0...ncoeffs do
        xx[i,j] = b[j]
      end
    end

    c, cov, chisq = GSL::MultiFit.wlinear(xx, w, y)

    bspline_samples = n # 150

    x2 = GSL::Vector.linspace(0, parameters.last, bspline_samples )
    y2 = GSL::Vector.alloc( bspline_samples )
    x2.each_index do |i|
      bw.eval(x2[i], b)
      yi, yerr = GSL::MultiFit::linear_est(b, c, cov)
      y2[i] = yi
    end

    GSL::graph([x, y], [x2, y2], "-T X -C -X x -Y y")

    return [x2, y2]
  end # }}}


end


# Direct Invocation (local testing) # {{{
if __FILE__ == $0

  spline = Spline.new

  # Test case 1  :=> cumulating_distance calculation
  # index       = 2
  # t           = 0
  # tuple       = [ 2, 3, 4, 5 ]
  # tuple_next  = [ 4, 6, 8, 10 ]
  # ap spline.cumulating_distance( index, t, tuple, tuple_next )

  # Read sample tdata
  data = File.open( "../../data/3d/non_linear/tdata.gpdata", "r" ).readlines
  data = spline.clean( data )                     # remove \t, \n, etc.
  rows = spline.extract_rows( data )
  parameters = spline.parametrization( rows )

  # Print x(t), y(t), z(t)
  columns = spline.extract_columns( data )
  # GSL::graph( [ GSL::Vector.alloc( parameters ), GSL::Vector.alloc( columns[0] ) ] )
  # GSL::graph( [ GSL::Vector.alloc( parameters ), GSL::Vector.alloc( columns[1] ) ] )
  # GSL::graph( [ GSL::Vector.alloc( parameters ), GSL::Vector.alloc( columns[2] ) ] )


  # first var is parameters - discard
  _, x = spline.bspline_smoothing( parameters, columns[0] )
  _, y = spline.bspline_smoothing( parameters, columns[1] )
  _, z = spline.bspline_smoothing( parameters, columns[2] )

  x = x.to_a
  y = y.to_a
  z = z.to_a

  res = []
  0.upto(x.length-1) { |i| res << [ x[i], y[i], z[i] ] }

  File.open("/tmp/tdata.gpdata", "w" ) do |f|
    res.each do |array|
      f.write( array.join(", ") + "\n" )
    end
  end

  # Spline fitting
  # Ref: http://ruby-gsl.sourceforge.net/spline.html
  # s = GSL::Spline.alloc( Interp::CSPLINE, data.length )
  # s.init( parameters, columns[0] )
  # res = []

  # parameters.each do |p|
  #   res << s.eval( p )
  # end

  # GSL::graph( [ GSL::Vector.alloc( parameters ), GSL::Vector.alloc( columns[0] ) ] )
  # GSL::graph( [ GSL::Vector.alloc( parameters ), GSL::Vector.alloc( res ) ] )




end # of if __FILE__ == $0 }}}

# vim:ts=2:tw=100:wm=100
