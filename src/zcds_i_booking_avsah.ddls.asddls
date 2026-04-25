@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface view for booking entity'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZCDS_I_BOOKING_AVSAH
  as select from zbooking_avsah
  association to parent ZCDS_I_TRAVEL_AVSAH as _travel on $projection.TravelId = _travel.TravelId
  composition [0..*] of ZCDS_I_BOOKINGSUPP_AVSAH as _booksup 
  association [0..1] to /DMO/I_Carrier           as _carrier       on  $projection.CarrierId = _carrier.AirlineID
  association [1..1] to /DMO/I_Connection        as _connection    on  $projection.CarrierId    = _connection.AirlineID
                                                                   and $projection.ConnectionId = _connection.ConnectionID
  association [1..1] to /DMO/I_Customer          as _customer      on  $projection.CustomerId = _customer.CustomerID
  association [1..1] to I_Currency               as _currency      on  $projection.CurrencyCode = _currency.Currency
  association [1..1] to /DMO/I_Booking_Status_VH as _bookingstatus on  $projection.BookingStatus = _bookingstatus.BookingStatus
{
  key travel_id       as TravelId,
  key booking_id      as BookingId,
      booking_date    as BookingDate,
      customer_id     as CustomerId,
      carrier_id      as CarrierId,
      connection_id   as ConnectionId,
      flight_date     as FlightDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      flight_price    as FlightPrice,
      currency_code   as CurrencyCode,
      booking_status  as BookingStatus,
      //this field is used for etag control
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      last_changed_at as LastChangedAt,
      _travel,
      _booksup,
      _carrier,
      _customer,
      _currency,
      _connection,
      _bookingstatus
}
