CLASS zswan_cx_rap_ai_doc DEFINITION
  PUBLIC
    INHERITING FROM cx_rap_query_provider
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        !iv_msgno TYPE symsgno
        !iv_attr1 TYPE scx_attrname OPTIONAL
        !iv_attr2 TYPE scx_attrname OPTIONAL
        !iv_attr3 TYPE scx_attrname OPTIONAL
        !iv_attr4 TYPE scx_attrname OPTIONAL
        !previous LIKE previous OPTIONAL .
    CONSTANTS c_message_class TYPE symsgid VALUE 'ZSWAN_AI_DOC'.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS zswan_cx_rap_ai_doc IMPLEMENTATION.
  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    CALL METHOD super->constructor
      EXPORTING
        previous = previous.
    CLEAR me->textid.
    if_t100_message~t100key-msgno = iv_msgno.
    if_t100_message~t100key-attr1 = iv_attr1.
    if_t100_message~t100key-attr2 = iv_attr2.
    if_t100_message~t100key-attr3 = iv_attr3.
    if_t100_message~t100key-attr4 = iv_attr4.
    if_t100_message~t100key-msgid = c_message_class.
  ENDMETHOD.
ENDCLASS.
