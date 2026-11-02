module WorkoutsHelper
  def signed_number(value, unit)
    number = number_with_precision(value, precision: 2, strip_insignificant_zeros: true)
    "#{value.positive? ? '+' : ''}#{number}#{unit}"
  end
end
