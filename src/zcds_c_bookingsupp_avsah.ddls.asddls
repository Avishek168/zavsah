@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Flight Reference:projection view booking supplement entity'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZCDS_C_BOOKINGSUPP_AVSAH 
as projection on ZCDS_I_BOOKINGSUPP_AVSAH
{
    key TravelId,
    key BookingId,
    key BookingSupplementId,
    @ObjectModel.text.element: [ 'SupplementDescription' ]
    SupplementId,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    Price,
    CurrencyCode,
    LastChangedAt,
    SupplementDescription,
    /* Associations */
    _booking: redirected to parent ZCDS_C_BOOKING_AVSAH,
    _travel: redirected to ZCDS_C_TRAVEL_AVSAH,
    _supplement,
    _supptext
}
