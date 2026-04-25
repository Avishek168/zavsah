@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Flight Reference:Projection view for travel entity'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZCDS_C_TRAVEL_AVSAH
  provider contract transactional_query
  as projection on ZCDS_I_TRAVEL_AVSAH

  //composition of target_data_source_name as _association_name
{
  key TravelId,
      @ObjectModel.text.element: [ 'AgencyName' ]
      AgencyId,
      _agency.Name              as AgencyName,
      @ObjectModel.text.element: [ 'CustomerName' ]
      CustomerId,
      _customer.LastName        as CustomerName,
      BeginDate,
      EndDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      BookingFee,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      TotalPrice,
      CurrencyCode,
      Description,
      @ObjectModel.text.element: [ 'OverallstatusText' ]
      OverallStatus,
      _overallstatus._Text.Text as OverallstatusText : localized,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      /* Associations */
      _agency,
      _booking : redirected to composition child ZCDS_C_BOOKING_AVSAH,
      _currency,
      _customer,
      _overallstatus
      //    _association_name // Make association public
}
