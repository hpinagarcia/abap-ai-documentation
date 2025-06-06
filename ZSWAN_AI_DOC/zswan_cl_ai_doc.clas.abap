CLASS zswan_cl_ai_doc DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    CONSTANTS c_object_type_class TYPE string VALUE 'CLAS' ##NO_TEXT.
    CONSTANTS c_object_type_interface TYPE string VALUE 'INTF' ##NO_TEXT.
    CONSTANTS c_object_type_package TYPE string VALUE 'DEVC' ##NO_TEXT.
    CONSTANTS c_object_type_dictionary TYPE string VALUE 'TABL' ##NO_TEXT.   " Table, Structure
    CONSTANTS c_object_type_program TYPE string VALUE 'PROG' ##NO_TEXT.
    CONSTANTS c_object_type_transaction TYPE string VALUE 'TRAN' ##NO_TEXT.
    CONSTANTS c_object_type_message_class TYPE string VALUE 'MSAG' ##NO_TEXT.
    CONSTANTS c_object_type_table_type TYPE string VALUE 'TTYP' ##NO_TEXT.
    CONSTANTS c_object_type_data_element TYPE string VALUE 'DTEL' ##NO_TEXT.
    CONSTANTS c_object_type_function_group TYPE string VALUE 'FUGR' ##NO_TEXT.
    CONSTANTS c_object_type_function_module TYPE string VALUE 'FUNC' ##NO_TEXT.
    CONSTANTS c_object_type_domain TYPE string VALUE 'DOMA' ##NO_TEXT. " Domain, Data element

    CLASS-METHODS get_all_package_contents
      IMPORTING
        !iv_package        TYPE devclass
      RETURNING
        VALUE(rt_contents) TYPE zswan_tt_ai_doc_object .
    CLASS-METHODS exists_package
      IMPORTING
        !iv_package      TYPE devclass
      RETURNING
        VALUE(rv_exists) TYPE abap_bool .
    CLASS-METHODS get_all_packages
      IMPORTING
        !iv_package        TYPE devclass
      RETURNING
        VALUE(rt_packages) TYPE gakh_t_tdevc .
    CLASS-METHODS get_object_description
      IMPORTING
        !iv_obj_name          TYPE sobj_name
        !iv_object_type       TYPE trobjtype
      RETURNING
        VALUE(rv_description) TYPE string .
ENDCLASS.



CLASS zswan_cl_ai_doc IMPLEMENTATION.


  METHOD exists_package.

    CLEAR: rv_exists.

    SELECT SINGLE * FROM tdevc
    INTO @DATA(ls_package)
    WHERE devclass = @iv_package.

    IF sy-subrc = 0.
      rv_exists = abap_true.
    ENDIF.
  ENDMETHOD.


  METHOD get_all_package_contents.

    DATA(lt_packages) = zswan_cl_ai_doc=>get_all_packages( iv_package ).

    CLEAR: rt_contents.

    DATA lt_filter TYPE RANGE OF tadir-object.

    APPEND VALUE #( sign = 'I' option = 'EQ' low = c_object_type_package ) TO lt_filter.
    APPEND VALUE #( sign = 'I' option = 'EQ' low = c_object_type_class ) TO lt_filter.
    APPEND VALUE #( sign = 'I' option = 'EQ' low = c_object_type_table_type ) TO lt_filter.
    APPEND VALUE #( sign = 'I' option = 'EQ' low = c_object_type_dictionary ) TO lt_filter.
    APPEND VALUE #( sign = 'I' option = 'EQ' low = c_object_type_interface ) TO lt_filter.
    APPEND VALUE #( sign = 'I' option = 'EQ' low = c_object_type_program ) TO lt_filter.
    APPEND VALUE #( sign = 'I' option = 'EQ' low = c_object_type_transaction ) TO lt_filter.
    APPEND VALUE #( sign = 'I' option = 'EQ' low = c_object_type_message_class ) TO lt_filter.
    APPEND VALUE #( sign = 'I' option = 'EQ' low = c_object_type_data_element ) TO lt_filter.
    APPEND VALUE #( sign = 'I' option = 'EQ' low = c_object_type_function_group ) TO lt_filter.
    APPEND VALUE #( sign = 'I' option = 'EQ' low = c_object_type_function_module ) TO lt_filter.
    APPEND VALUE #( sign = 'I' option = 'EQ' low = c_object_type_domain ) TO lt_filter.

    LOOP AT lt_packages INTO DATA(ls_package).

      SELECT * FROM tadir
        INTO TABLE @DATA(lt_objects)
        WHERE devclass = @ls_package-devclass
        AND delflag = ''
        AND object IN @lt_filter.

      LOOP AT lt_objects INTO DATA(ls_object).

        APPEND INITIAL LINE TO rt_contents ASSIGNING FIELD-SYMBOL(<fs_content>).
        <fs_content>-pgmid = ls_object-pgmid.
        <fs_content>-obj_name = ls_object-devclass.
        <fs_content>-object = ls_object-object.
        <fs_content>-obj_name = ls_object-obj_name.
        <fs_content>-devclass = ls_object-devclass.

        <fs_content>-description = get_object_description(
                                   iv_obj_name    = <fs_content>-obj_name
                                   iv_object_type = <fs_content>-object ).

      ENDLOOP.

    ENDLOOP.


  ENDMETHOD.


  METHOD get_all_packages.

    DATA: lt_subpkgs  TYPE TABLE OF tdevc,
          lv_subpkg   TYPE devclass,
          lt_all_pkgs TYPE TABLE OF tdevc.

    CLEAR: rt_packages.

    SELECT SINGLE * FROM tdevc
        WHERE devclass = @iv_package
        INTO @DATA(ls_package).

    APPEND ls_package TO lt_all_pkgs.

    SELECT * FROM tdevc
      INTO TABLE @lt_subpkgs
      WHERE parentcl = @iv_package.

    LOOP AT lt_subpkgs INTO lv_subpkg.
      APPEND LINES OF zswan_cl_ai_doc=>get_all_packages( lv_subpkg ) TO lt_all_pkgs.
    ENDLOOP.

    rt_packages = lt_all_pkgs.

  ENDMETHOD.


  METHOD get_object_description.

    CLEAR: rv_description.

    CASE iv_object_type.

      WHEN c_object_type_package.
        cl_package_factory=>load_package(
          EXPORTING
            i_package_name             = CONV devclass( iv_obj_name )
          IMPORTING
            e_package                  = DATA(lo_package)
        ).
        IF sy-subrc = 0.
          rv_description = lo_package->short_text.
        ENDIF.

      WHEN c_object_type_class OR c_object_type_interface.
        SELECT SINGLE descript
            FROM seoclasstx
            WHERE clsname = @iv_obj_name
            AND langu    = @sy-langu
            INTO @rv_description.

      WHEN c_object_type_dictionary.
        SELECT SINGLE ddtext
            FROM dd02t
            WHERE tabname = @iv_obj_name
            AND ddlanguage    = @sy-langu
            INTO @rv_description.

      WHEN c_object_type_message_class.
        SELECT SINGLE stext
            FROM t100a
            WHERE arbgb  = @iv_obj_name
            AND masterlang    = @sy-langu
            INTO @rv_description.

      WHEN c_object_type_transaction.
        SELECT SINGLE ttext
            FROM tstct
            INTO @rv_description
            WHERE tcode = @iv_obj_name
            AND sprsl = @sy-langu.

      WHEN c_object_type_domain.
        SELECT SINGLE ddtext
            FROM dd01t
            INTO @rv_description
            WHERE domname = @iv_obj_name
            AND ddlanguage = @sy-langu.

      WHEN c_object_type_data_element.
        SELECT SINGLE ddtext
            FROM dd04t
            INTO @rv_description
            WHERE rollname = @iv_obj_name
            AND ddlanguage = @sy-langu.

      WHEN c_object_type_table_type.
        SELECT SINGLE ddtext
                    FROM dd02t
                    INTO @rv_description
                    WHERE tabname = @iv_obj_name
                    AND ddlanguage = @sy-langu.
    ENDCASE.

  ENDMETHOD.
ENDCLASS.
