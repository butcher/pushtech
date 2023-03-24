class Reservation
  include Mongoid::Document
  include Mongoid::Timestamps

  CURRENCIES = Money::Currency.select{|c| c.priority < 10}.map(&:id)

  field :hotel_name, type: String
  field :price, type: Integer
  field :currency, type: StringifiedSymbol
  field :checkin_date, type: Date
  field :checkout_date, type: Date
  field :guest_full_name, type: String
  field :guest_email, type: String

  validates_presence_of :hotel_name, :price, :currency, :checkin_date, :checkout_date, :guest_full_name, :guest_email
  validates :price, numericality: { only_integer: true, greater_than: 0 }
  validates :currency, inclusion: CURRENCIES
  validate :validate_reservation_length
  validates :guest_email, format: { with: URI::MailTo::EMAIL_REGEXP }

  private

  def validate_reservation_length
    errors.add(:base, 'Reservation length should be at least one day long') if checkin_date && checkout_date && checkin_date >= checkout_date
  end
end
