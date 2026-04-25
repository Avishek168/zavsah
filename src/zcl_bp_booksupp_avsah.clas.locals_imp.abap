CLASS lhc_booksupp DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS calculateTotalPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Booksupp~calculateTotalPrice.

ENDCLASS.

CLASS lhc_booksupp IMPLEMENTATION.

  METHOD calculateTotalPrice.

    DATA: lt_travelid_booksupp TYPE STANDARD TABLE OF zcds_i_travel_avsah WITH UNIQUE HASHED KEY key COMPONENTS TravelId.

    lt_travelid_booksupp = CORRESPONDING #( keys DISCARDING DUPLICATES MAPPING TravelId = TravelId ).
    MODIFY ENTITIES OF zcds_i_travel_avsah IN LOCAL MODE
    ENTITY Travel EXECUTE reCalTotalPrice
    FROM CORRESPONDING #( lt_travelid_booksupp ) .

  ENDMETHOD.

ENDCLASS.

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
