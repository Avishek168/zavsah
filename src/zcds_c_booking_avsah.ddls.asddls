@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Flight Ref:Projection view booking entity'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZCDS_C_BOOKING_AVSAH 
as projection on ZCDS_I_BOOKING_AVSAH
{
    key TravelId,
    key BookingId,
    BookingDate,
    @ObjectModel.text.element: [ 'CustomerName' ]
    CustomerId,
    _customer.LastName as CustomerName,
    @ObjectModel.text.element: [ 'CarrierName' ]
    CarrierId,
    _carrier.Name as CarrierName,
    ConnectionId,
    FlightDate,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    FlightPrice,
    CurrencyCode,
    @ObjectModel.text.element: [ 'BookingStatustext' ]
    BookingStatus,
    _bookingstatus._Text.Text as BookingStatustext:localized,
    LastChangedAt,
    /* Associations */
    _bookingstatus,
    _booksup: redirected to composition child ZCDS_C_BOOKINGSUPP_AVSAH,
    _carrier,
    _connection,
    _currency,
    _customer,
    _travel:redirected to parent ZCDS_C_TRAVEL_AVSAH
}
