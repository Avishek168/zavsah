CLASS zcl_avsah_data_transfer DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES: if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_AVSAH_DATA_TRANSFER IMPLEMENTATION.


  METHOD: if_oo_adt_classrun~main.
    DELETE FROM ztravel_avsah.
    DELETE FROM zbooking_avsah.
    DELETE FROM zbooksupp_avsah.
    COMMIT WORK.

    INSERT ztravel_avsah FROM (  SELECT * FROM /dmo/travel_m ). COMMIT WORK.
    INSERT zbooking_avsah FROM (  SELECT * FROM /dmo/booking_m ) . COMMIT WORK.
    INSERT zbooksupp_avsah FROM (  SELECT *  FROM /dmo/booksuppl_m ). COMMIT WORK.
  ENDMETHOD.
ENDCLASS.
