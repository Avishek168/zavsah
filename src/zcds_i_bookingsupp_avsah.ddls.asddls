@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface view booking supplement entity'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZCDS_I_BOOKINGSUPP_AVSAH
  as select from zbooksupp_avsah
  association to parent ZCDS_I_BOOKING_AVSAH as _booking on  $projection.TravelId = _booking.TravelId and
                                                             $projection.BookingId = _booking.BookingId
  association[0..1] to ZCDS_I_TRAVEL_AVSAH as _travel on $projection.TravelId = _travel.TravelId
                                                      
  association [1..1] to /dmo/supplement as _supplement on  $projection.BookingSupplementId = _supplement.supplement_id
  association [1..1] to /dmo/suppl_text as _supptext   on  $projection.SupplementId = _supptext.supplement_id
                                                       and _supptext.language_code  = $session.system_language
{
  key travel_id             as TravelId,
  key booking_id            as BookingId,
  key booking_supplement_id as BookingSupplementId,
      supplement_id         as SupplementId,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      price                 as Price,
      currency_code         as CurrencyCode,
      _supptext.description as SupplementDescription,
      //used for etag control
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      last_changed_at       as LastChangedAt,
      _booking,
      _travel,
      _supplement,
      _supptext
}
