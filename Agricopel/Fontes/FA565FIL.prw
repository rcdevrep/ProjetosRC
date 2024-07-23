#INCLUDE 'Protheus.ch'

/*/{Protheus.doc} FA565FIL
- Chamado 287581 - Filtrar por E1_EMISSAO  ao inves de E1_EMIS1(FINA565)
@author Leandro Spiller
@since 04/02/2020
@return _cFiltro
@type function
/*/
User Function FA565FIL()
	
    Local _cQuery := ""
    Local _oDlg
    Local oButton1
    Local oDataAte
    Local dDataAte := Date()
    Local oDatade
    Local dDatade := Date()
    Local oSay1
    Local oSay2
    Local oSay3
    Local oSay4
    Local _lConfirm := .f.
    
    //If nIntervalo == 1
        
    DEFINE MSDIALOG _oDlg TITLE "Filtrar por Emissao (FA565FIL-E2_EMIS1)" FROM 000, 000  TO 120, 280 COLORS 0, 16777215 PIXEL

        @ 009, 045 MSGET oDatade VAR dDatade SIZE 060, 010 OF _oDlg COLORS 0, 16777215 PIXEL
        @ 026, 045 MSGET oDataAte VAR dDataAte SIZE 060, 010 OF _oDlg COLORS 0, 16777215 PIXEL
        @ 011, 005 SAY oSay1 PROMPT "Emissao de " SIZE 033, 007 OF _oDlg COLORS 0, 16777215 PIXEL
        @ 029, 005 SAY oSay2 PROMPT "Emissao ate " SIZE 033, 007 OF _oDlg COLORS 0, 16777215 PIXEL
        @ 043, 088 BUTTON oButton1 PROMPT "Confirma" ACTION( _lConfirm := .T., _oDlg:End()) SIZE 037, 012 OF _oDlg PIXEL
        @ 041, 001 SAY oSay3 PROMPT "(*)Criado, pois por padrão"  SIZE 076, 007 OF _oDlg COLORS 255, 16777215 PIXEL
        @ 051, 001 SAY oSay4 PROMPT "filtra por Dt. contabilização "   SIZE 080, 007 OF _oDlg COLORS 255, 16777215 PIXEL

    ACTIVATE MSDIALOG _oDlg
    
    If _lConfirm       
        _cQuery += " and E2_EMISSAO >= '" + DTOS(dDatade) + "'"
        _cQuery += " and E2_EMISSAO <= '" + DTOS(dDataAte) + "'"
    Else
        If !(Msgyesno('Deseja IGNORAR o Filtro de Emissao?','Cancelar'))
            _cQuery += " and E2_EMISSAO >= '" + DTOS(dDatade) + "'"
            _cQuery += " and E2_EMISSAO <= '" + DTOS(dDataAte) + "'"
        Endif 
    Endif
    //Endif
    
Return _cQuery