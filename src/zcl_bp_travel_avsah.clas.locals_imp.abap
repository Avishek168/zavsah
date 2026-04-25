CLASS lhc_ZCDS_I_TRAVEL_AVSAH DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zcds_i_travel_avsah RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zcds_i_travel_avsah RESULT result.

    METHODS accepttravel FOR MODIFY
      IMPORTING keys FOR ACTION travel~accepttravel RESULT result.

    METHODS copytravel FOR MODIFY
      IMPORTING keys FOR ACTION travel~copytravel.

    METHODS recaltotalprice FOR MODIFY
      IMPORTING keys FOR ACTION travel~recaltotalprice.

    METHODS rejecttravel FOR MODIFY
      IMPORTING keys FOR ACTION travel~rejecttravel RESULT result.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR travel RESULT result.
    METHODS validatecustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR travel~validatecustomer.
    METHODS validatedates FOR VALIDATE ON SAVE
      IMPORTING keys FOR travel~validatedates.
    METHODS calculatetotalprice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR travel~calculatetotalprice.

    METHODS earlynumbering_cba_booking FOR NUMBERING
      IMPORTING entities FOR CREATE travel\_booking.

    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE travel.

ENDCLASS.

CLASS lhc_ZCDS_I_TRAVEL_AVSAH IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD earlynumbering_create.

    "putting entities in a local internal table
    DATA(lt_entities) = entities.
    DELETE lt_entities WHERE TravelId IS NOT INITIAL. "deleting the entries where travel id is having values.

    "call class method to create next number
    TRY.
        cl_numberrange_runtime=>number_get(
          EXPORTING
*        ignore_buffer     =
            nr_range_nr       = '01'
            object            = '/DMO/TRV_M'
            quantity          = CONV #( lines( lt_entities ) )

          IMPORTING
            number            = DATA(lv_number)
            returncode        = DATA(lv_returncode)
            returned_quantity = DATA(lv_returned_quantity)
        ).
      CATCH cx_nr_object_not_found.
      CATCH cx_number_ranges INTO DATA(lo_error).
        "in case of any exception show the error message by following
        LOOP AT lt_entities INTO DATA(lwa_entities).
          APPEND VALUE #(
                         %cid = lwa_entities-%cid
                         TravelId = lwa_entities-TravelId
                        ) TO failed-travel.

          APPEND VALUE #( %cid = lwa_entities-%cid
                          travelid = lwa_entities-TravelId
                          %msg = lo_error
                          ) TO reported-travel.
        ENDLOOP.
        EXIT.
    ENDTRY.

    ASSERT lv_returned_quantity = lines( lt_entities ).
    DATA(lv_current_number) = lv_number - lv_returned_quantity. "find out current number in system

    DATA: lt_mapped TYPE TABLE FOR MAPPED EARLY zcds_i_travel_avsah,
          ls_mapped LIKE LINE OF lt_mapped.
    LOOP AT lt_entities INTO DATA(ls_entities).

      lv_current_number = lv_current_number + 1.
      ls_mapped = VALUE #( %cid = ls_entities-%cid
                           TravelId = lv_current_number ).
      APPEND ls_mapped TO mapped-travel. "assign the latest number to travel id
    ENDLOOP.

  ENDMETHOD.

  METHOD earlynumbering_cba_Booking.

    DATA: lv_max_bookingid TYPE /dmo/booking_id.

    READ ENTITIES OF zcds_i_travel_avsah IN LOCAL MODE
    ENTITY Travel BY \_booking
    FROM CORRESPONDING #( entities )
    LINK DATA(lt_link_data).

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<lfs_entities>) GROUP BY <lfs_entities>-TravelId.

      lv_max_bookingid = REDUCE #( INIT lv_max TYPE /dmo/booking_id
                                   FOR ls_link_data IN lt_link_data
                                   USING KEY entity WHERE ( source-TravelId EQ <lfs_entities>-TravelId )
                                   NEXT lv_max = COND #( WHEN lv_max < ls_link_data-target-BookingId
                                                         THEN ls_link_data-target-BookingId
                                                         ELSE lv_max )
                                 ).

      "additional check for draft functionality,can be ignored if draft functionality is not there
      lv_max_bookingid = REDUCE #( INIT lv_max = lv_max_bookingid
                                   FOR ls_entities IN entities USING KEY entity
                                   WHERE ( travelid = <lfs_entities>-TravelId )
                                   FOR ls_target IN ls_entities-%target
                                   NEXT lv_max = COND #( WHEN lv_max LT ls_target-BookingId
                                                         THEN ls_target-BookingId
                                                         ELSE lv_max )
                                 ).

      LOOP AT entities ASSIGNING FIELD-SYMBOL(<lfs_entities_t>)
                                             USING KEY entity
                                             WHERE TravelId EQ <lfs_entities>-TravelId .
        LOOP AT <lfs_entities_t>-%target ASSIGNING FIELD-SYMBOL(<lfs_target>).
          APPEND CORRESPONDING #( <lfs_target> ) TO mapped-booking ASSIGNING FIELD-SYMBOL(<lfs_booking>).
          IF <lfs_target>-BookingId IS INITIAL.
            lv_max_bookingid += 10.
            <lfs_booking>-BookingId = lv_max_bookingid.

          ENDIF.

        ENDLOOP.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD acceptTravel.

    MODIFY ENTITIES OF zcds_i_travel_avsah IN LOCAL MODE
    ENTITY Travel UPDATE FIELDS (  OverallStatus )
    WITH VALUE #(  FOR ls_keys IN keys ( %tky = ls_keys-%tky
                                                                        OverallStatus = 'A' ) )
    REPORTED DATA(lt_reported)
    MAPPED DATA(lt_mapped)
    FAILED DATA(lt_failed).


    READ ENTITIES OF zcds_i_travel_avsah IN LOCAL MODE
    ENTITY Travel ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result).

    result = VALUE #( FOR ls_result IN lt_result ( %tky = ls_result-%tky
                                                                               %param = ls_result  ) ).
  ENDMETHOD.

  METHOD copyTravel.

    DATA:
      lt_travel_new   TYPE TABLE FOR CREATE zcds_i_travel_avsah,
      lt_booking_new  TYPE TABLE FOR CREATE zcds_i_travel_avsah\_booking,
      lt_booksupp_new TYPE TABLE FOR CREATE zcds_i_booking_avsah\_booksup.

    "read table with existing keys if not available then short dump raised
    READ TABLE keys ASSIGNING FIELD-SYMBOL(<lfs_wo_keys>) WITH KEY %cid = ' '.
    ASSERT <lfs_wo_keys> IS NOT ASSIGNED.

    "read entities of the travel instance need to copy

    "read travel entity
    READ ENTITIES OF zcds_i_travel_avsah IN LOCAL MODE
    ENTITY Travel ALL FIELDS WITH CORRESPONDING #(  keys )
    RESULT DATA(lt_travel_read)
    FAILED DATA(lt_travel_read_failed).

    "read booking entity by association
    READ ENTITIES OF zcds_i_travel_avsah IN LOCAL MODE
    ENTITY travel  BY \_booking
    ALL FIELDS WITH CORRESPONDING #( lt_travel_read )
    RESULT DATA(lt_booking_read).

    "read booking supplement entity by association of booking entity
    READ ENTITIES OF zcds_i_travel_avsah IN LOCAL MODE
    ENTITY Booking BY \_booksup
    ALL FIELDS WITH CORRESPONDING #( lt_booking_read )
    RESULT DATA(lt_booksupp_read).


    LOOP AT lt_travel_read ASSIGNING FIELD-SYMBOL(<lfs_travel_read>).

      "fill travel entity for the new instance
      APPEND VALUE #( %cid = keys[ KEY entity TravelId = <lfs_travel_read>-TravelId ]-%cid
                                    %data = CORRESPONDING #( <lfs_travel_read> EXCEPT TravelId ) )
                                    TO lt_travel_new ASSIGNING FIELD-SYMBOL(<lfs_travel_new>).
      <lfs_travel_new>-BeginDate = cl_abap_context_info=>get_system_date(  ).
      <lfs_travel_new>-EndDate =   cl_abap_context_info=>get_system_date(  ) + 30.
      <lfs_travel_new>-OverallStatus = 'O'.

      "fill booking entity for new instance
      APPEND VALUE #( %cid_ref = <lfs_travel_new>-%cid ) TO lt_booking_new ASSIGNING FIELD-SYMBOL(<lfs_booking_new>).

      LOOP AT lt_booking_read ASSIGNING FIELD-SYMBOL(<lfs_booking_read>) USING KEY entity
                                                                                        WHERE  TravelId = <lfs_travel_read>-TravelId.
        APPEND VALUE #( %cid = <lfs_travel_new>-%cid && <lfs_booking_read>-BookingId
                                            %data = CORRESPONDING #( <lfs_booking_read> EXCEPT travelid ) )
                                            TO <lfs_booking_new>-%target ASSIGNING FIELD-SYMBOL(<lfs_booking_target>).

        <lfs_booking_target>-BookingStatus = 'N'.

      ENDLOOP.

      "fill booking supplement entity
      APPEND VALUE #( %cid_ref = <lfs_booking_new>-%cid_ref )
                                     TO lt_booksupp_new ASSIGNING FIELD-SYMBOL(<lfs_booksupp_new>).

      LOOP AT lt_booksupp_read ASSIGNING FIELD-SYMBOL(<lfs_booksupp_read>) USING KEY entity
                                                                        WHERE TravelId = <lfs_travel_read>-TravelId AND
                                                                        BookingId = <lfs_booking_read>-BookingId .

        APPEND VALUE #(  %cid = <lfs_travel_new>-%cid && <lfs_booking_read>-BookingId && <lfs_booksupp_read>-BookingSupplementId
                                      %data = CORRESPONDING #( <lfs_booksupp_read> EXCEPT travelid bookingid  ) )
                                      TO <lfs_booksupp_new>-%target .

      ENDLOOP.
    ENDLOOP.

    MODIFY ENTITIES OF zcds_i_travel_avsah IN LOCAL MODE
    ENTITY Travel
    CREATE FIELDS (  AgencyId BeginDate BookingFee  CurrencyCode CustomerId Description EndDate OverallStatus TotalPrice )
    WITH lt_travel_new
    ENTITY travel
    CREATE BY \_booking
    FIELDS ( BookingId BookingDate BookingStatus CarrierId ConnectionId CurrencyCode CustomerId FlightDate FlightPrice )
    WITH lt_booking_new
    ENTITY Booking
    CREATE BY \_booksup
    FIELDS (  BookingSupplementId SupplementId price CurrencyCode )
    WITH lt_booksupp_new
    MAPPED DATA(lt_mapped)
    FAILED DATA(lt_failed)
    REPORTED DATA(lt_reported).

    mapped-travel = lt_mapped-travel.
    failed-travel = lt_failed-travel.
    reported-travel = lt_reported-travel.

  ENDMETHOD.

  METHOD reCalTotalPrice.

    TYPES: BEGIN OF ty_price,
             price    TYPE /dmo/total_price,
             currency TYPE /dmo/currency_code,
           END OF ty_price.

    DATA: lt_price TYPE STANDARD TABLE OF ty_price.


    READ ENTITIES OF zcds_i_travel_avsah IN LOCAL MODE
    ENTITY Travel FIELDS ( BookingFee CurrencyCode )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_travel).

    READ ENTITIES OF zcds_i_travel_avsah IN LOCAL MODE
    ENTITY Travel BY \_booking
    FIELDS ( FlightPrice CurrencyCode )
    WITH CORRESPONDING #(  lt_travel )
    RESULT DATA(lt_booking).

    READ ENTITIES OF zcds_i_travel_avsah IN LOCAL MODE
    ENTITY Booking BY \_booksup
    FIELDS ( Price CurrencyCode )
    WITH CORRESPONDING #( lt_booking )
    RESULT DATA(lt_booksupp).

    LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<lfs_travel>).

      APPEND VALUE #( price = <lfs_travel>-BookingFee
                                  currency = <lfs_travel>-CurrencyCode
                                  ) TO lt_price.

      LOOP AT lt_booking ASSIGNING FIELD-SYMBOL(<lfs_booking>) USING KEY entity WHERE TravelId = <lfs_travel>-TravelId
                                                                                                                                            AND CurrencyCode IS NOT INITIAL.

        APPEND VALUE #( price = <lfs_booking>-FlightPrice
                                    currency = <lfs_booking>-CurrencyCode
                                    ) TO lt_price.

      ENDLOOP.

      IF lt_booksupp IS NOT INITIAL.
        LOOP AT lt_booksupp ASSIGNING FIELD-SYMBOL(<lfs_booksupp>) USING KEY entity WHERE TravelId = <lfs_travel>-TravelId AND
                                                                                                                              BookingId = <lfs_booking>-BookingId AND
                                                                                                                              CurrencyCode IS NOT INITIAL.
          APPEND VALUE #( price = <lfs_booksupp>-Price
                                     currency = <lfs_booksupp>-CurrencyCode ) TO lt_price.

        ENDLOOP.
      ENDIF.
      LOOP AT lt_price  ASSIGNING FIELD-SYMBOL(<lfs_price>).
        IF <lfs_price>-currency EQ <lfs_travel>-CurrencyCode.
          DATA(lv_conv_currency) = <lfs_price>-price.
        ELSE.
          /dmo/cl_flight_amdp=>convert_currency(
            EXPORTING
              iv_amount               = <lfs_price>-price
              iv_currency_code_source =  <lfs_price>-currency
              iv_currency_code_target = <lfs_travel>-CurrencyCode
              iv_exchange_rate_date   = cl_abap_context_info=>get_system_date( )
            IMPORTING
              ev_amount               = lv_conv_currency
          ).
        ENDIF.

        <lfs_travel>-TotalPrice = <lfs_travel>-TotalPrice + lv_conv_currency.

      ENDLOOP.
    ENDLOOP.

    MODIFY ENTITIES OF zcds_i_travel_avsah IN LOCAL MODE
    ENTITY Travel UPDATE FIELDS ( TotalPrice )
    WITH CORRESPONDING #( lt_travel ).



  ENDMETHOD.

  METHOD rejectTravel.

    MODIFY ENTITIES OF zcds_i_travel_avsah IN LOCAL MODE
      ENTITY Travel UPDATE FIELDS (  OverallStatus )
      WITH VALUE #(  FOR ls_keys IN keys ( %tky = ls_keys-%tky
                                                                          OverallStatus = 'X' ) )
      REPORTED DATA(lt_reported)
      MAPPED DATA(lt_mapped)
      FAILED DATA(lt_failed).


    READ ENTITIES OF zcds_i_travel_avsah IN LOCAL MODE
    ENTITY Travel ALL FIELDS WITH VALUE #( FOR lfs_keys IN keys ( %tky = lfs_keys-%tky ) )
    RESULT DATA(lt_result).

    result = VALUE #( FOR ls_result IN lt_result ( %tky = ls_result-%tky
                                                                                 %param = ls_result ) ).

  ENDMETHOD.

  METHOD get_instance_features.

    READ ENTITIES OF zcds_i_travel_avsah IN LOCAL MODE
    ENTITY Travel FIELDS (  TravelId OverallStatus )
    WITH CORRESPONDING #(  keys )
    RESULT DATA(lt_result).


    result = VALUE #( FOR ls_result IN lt_result
                                   (  %tky = ls_result-%tky
                                     %features-%action-acceptTravel = COND #(  WHEN ls_result-OverallStatus EQ 'A' THEN if_abap_behv=>fc-o-disabled
                                                                                                                     ELSE if_abap_behv=>fc-o-enabled  )
                                   %features-%action-rejectTravel = COND #( WHEN ls_result-OverallStatus EQ 'X' THEN if_abap_behv=>fc-o-disabled
                                                                                                                     ELSE if_abap_behv=>fc-o-enabled )
                                   %features-%assoc-_booking =  COND #(  WHEN ls_result-OverallStatus EQ 'A' THEN if_abap_behv=>fc-o-enabled
                                                                                                                  WHEN ls_result-OverallStatus EQ 'O' THEN if_abap_behv=>fc-o-enabled
                                                                                                                     ELSE if_abap_behv=>fc-o-disabled  )
                                   )
                                ).



  ENDMETHOD.

  METHOD validateCustomer.

    READ ENTITIES OF zcds_i_travel_avsah IN LOCAL MODE
    ENTITY Travel FIELDS ( CustomerId )
     WITH CORRESPONDING #(  keys )
     RESULT DATA(lt_result).

    SORT lt_result BY CustomerId.
    DELETE ADJACENT DUPLICATES FROM lt_result COMPARING CustomerId.
    IF lt_result IS NOT INITIAL.
      SELECT
                  FROM /dmo/customer
                  FIELDS customer_id
                  FOR ALL ENTRIES IN @lt_result
                  WHERE customer_id = @lt_result-CustomerId
                  INTO TABLE @DATA(lt_customer).
      IF sy-subrc EQ 0.
        SORT lt_customer BY customer_id.
      ENDIF.
      LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<lfs_result>).
        IF <lfs_result>-CustomerId IS INITIAL
          OR  NOT line_exists( lt_customer[ customer_id = <lfs_result>-CustomerId ] ).

          APPEND VALUE #( %tky = <lfs_result>-%tky )
                                                             TO failed-travel.

          APPEND VALUE #( %tky = <lfs_result>-%tky
                                            %msg = NEW /dmo/cm_flight_messages(
                                                                                         textid = /dmo/cm_flight_messages=>customer_unkown
                                                                                         customer_id = <lfs_result>-CustomerId
                                                                                         severity = if_abap_behv_message=>severity-error   )
                                           %element-customerid = if_abap_behv=>mk-on
                                            )
                                                 TO reported-travel.

        ENDIF.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.

  METHOD validateDates.

    READ ENTITIES OF zcds_i_travel_avsah IN LOCAL MODE
    ENTITY Travel FIELDS ( BeginDate EndDate )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result).

    LOOP AT lt_result  ASSIGNING FIELD-SYMBOL(<lfs_result>).
      IF <lfs_result>-BeginDate GT <lfs_result>-EndDate.

        APPEND VALUE #( %tky = <lfs_result>-%tky ) TO failed-travel.
        APPEND VALUE #(
                                         %tky = <lfs_result>-%tky
                                         %msg = NEW /dmo/cm_flight_messages(
                                                             textid = /dmo/cm_flight_messages=>begin_date_bef_end_date
                                                             severity = if_abap_behv_message=>severity-error
                                                             begin_date = <lfs_result>-BeginDate
                                                             end_date = <lfs_result>-EndDate    )
                                             %element = VALUE #( begindate = if_abap_behv=>mk-on
                                                                                   enddate = if_abap_behv=>mk-off )
                                         ) TO reported-travel.

      ELSEIF <lfs_result>-BeginDate LT cl_abap_context_info=>get_system_date(  ).
        APPEND VALUE #( %tky = <lfs_result>-%tky ) TO failed-travel.
        APPEND VALUE #(
                                         %tky = <lfs_result>-%tky
                                         %msg = NEW /dmo/cm_flight_messages(
                                                             textid = /dmo/cm_flight_messages=>begin_date_on_or_bef_sysdate
                                                             severity = if_abap_behv_message=>severity-error
                                                             begin_date = <lfs_result>-BeginDate
                                                             end_date = <lfs_result>-EndDate    )
                                             %element = VALUE #( begindate = if_abap_behv=>mk-on
                                                                                   enddate = if_abap_behv=>mk-off )
                                         ) TO reported-travel.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD calculateTotalPrice.

    MODIFY ENTITIES OF zcds_i_travel_avsah IN LOCAL MODE
    ENTITY Travel EXECUTE reCalTotalPrice
    FROM CORRESPONDING #( keys ).


  ENDMETHOD.

ENDCLASS.
