@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'booking approver'
@Metadata.ignorePropagatedAnnotations: true
@UI.headerInfo: {
    typeName: 'Booking',
    typeNamePlural: 'Bookings',
    title: {
        type: #STANDARD,
        label: 'Bookings',
        criticalityRepresentation: #WITHOUT_ICON,
        value: 'BookingId'
    }
}
define view entity zcds_c_Booking_approver_avsah
  as projection on ZCDS_I_BOOKING_AVSAH
{
 @UI.facet: [
  {
      id: 'Booking',
      purpose: #STANDARD,
      position: 10,
      label: 'Booking',
      type: #IDENTIFICATION_REFERENCE

  }
  ]
  key TravelId,
  @UI:{
        lineItem: [{ position: 10 }],
        identification: [{ position: 10 }]
      }
  key BookingId,
    @UI:{
       lineItem: [{ position: 20 }],
       identification: [{ position: 15 }]
      }
      BookingDate,
        @UI:{
       lineItem: [{ position: 30 }],
       identification: [{ position: 20 }]
      }
  @Consumption.valueHelpDefinition: [{ entity: {
                                 name: '/dmo/i_customer',
                                 element: 'CustomerID'
                             } }]
      @ObjectModel.text.element: [ 'CustomerName' ]
      CustomerId,
      @UI.hidden: true
      _customer.LastName        as CustomerName,
        @UI:{
       lineItem: [{ position: 40 }],
       identification: [{ position: 25 }]
      }
  @Consumption.valueHelpDefinition: [{ entity: {
                                           name: '/DMO/I_Flight',
                                           element: 'AirlineID'
                                       } }]
      @ObjectModel.text.element: [ 'CarrierName' ]
      CarrierId,
      @UI.hidden: true
      _carrier.Name             as CarrierName,
        @UI:{
       lineItem: [{ position: 50 }],
       identification: [{ position: 30 }]
      }
  @Consumption.valueHelpDefinition: [{ entity: {
                                           name: '/DMO/I_Flight',
                                           element: 'ConnectionID'
                                       },
                                       additionalBinding: [
                                                         { element: 'AirlineID',
                                                            localElement: 'CarrierId' },
                                                         { element: 'Price',
                                                             localElement: 'FlightPrice'},
                                                         { element: 'FlightDate',
                                                             localElement: 'FlightDate'},
                                                         { element: 'CurrencyCode',
                                                             localElement: 'CurrencyCode'}
                                                            ]

                                    }]
      ConnectionId,
        @UI:{
       lineItem: [{ position: 60 }],
       identification: [{ position: 35 }]
      }

  @Consumption.valueHelpDefinition: [{ entity: {
                                           name: '/DMO/I_Flight',
                                           element: 'FlightDate'
                                       },
                                       additionalBinding: [
                                                            { element: 'ConnectionID',
                                                             localElement: 'ConnectionID' },
                                                            { element: 'AirlineID',
                                                              localElement: 'CarrierID'},
                                                              { element: 'Price',
                                                              localElement: 'FlightPrice'},
                                                               { element: 'CurrencyCode',
                                                              localElement: 'CurrencyCode'}
                                                             ]
                                        }]
      FlightDate,
        @UI:{
     lineItem: [{ position: 70 }],
     identification: [{ position: 40 }]
    }
      @Semantics.amount.currencyCode: 'CurrencyCode'
      FlightPrice,
        @Consumption.valueHelpDefinition: [{ entity: {
                                         name: 'i_currency',
                                         element: 'Currency'
                                     } }]
      CurrencyCode,
        @UI:{
       lineItem: [{ position: 80 }],
       identification: [{ position: 450 }],
       textArrangement: #TEXT_ONLY
      }
  @Consumption.valueHelpDefinition: [{ entity: {
                                     name: '/DMO/I_Booking_Status_VH',
                                     element: 'BookingStatus'
                                 } }]
      @ObjectModel.text.element: [ 'BookingStatustext' ]
      BookingStatus,
      @UI.hidden: true
      _bookingstatus._Text.Text as BookingStatustext : localized,
      LastChangedAt,
      /* Associations */
      _bookingstatus,
//      _booksup,
      _carrier,
      _connection,
      _currency,
      _customer,
      _travel : redirected to parent zcds_c_travel_approver_avsah
}
