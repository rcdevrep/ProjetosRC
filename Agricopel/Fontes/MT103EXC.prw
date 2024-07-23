#INCLUDE 'topconn.ch'
//---------------------------------------------------------------------
/*/{Protheus.doc} MT103EXC
PE para validação da exclusão do documento de entrada.

@author     Dirlei@uxpert
@since      10/11/2022

@return     lRet, .T.
@type       function
/*/
//---------------------------------------------------------------------
User Function MT103EXC()

    Local lRet := .T.
    Local _cQuery := ''

    Private cProduto    := PadR((SuperGetMV("AG_PRODREM",.F.,"00338")),TamSX3("B1_COD")[1])
    Private cProdOp     := PadR((SuperGetMV("AG_PRODOP",.F.,"44380001")),TamSX3("B1_COD")[1])
    Private nQtdeOp     := 0
    Private _cServico   := PadR((SuperGetMV("AG_PRDSERV",.F.,"401138")),TamSX3("B1_COD")[1])//Produto do serviço
    Private _lGeraOP    := SuperGetMV("AG_ARLAOP",.F.,.F.)//Gera OP Para ARLA

    If _lGeraOP
        If alltrim(SF1->F1_ESPECIE) <> 'CTE'
            
            _cQuery := " SELECT D1_FILIAL,D1_OP,R_E_C_N_O_ as RECNO,D1_OP FROM "+RetsqlName('SD1')+" (NOLOCK) "
            _cQuery += " WHERE "
            _cQuery += " D1_DOC         =  '"+SD1->D1_DOC+"' "
            _cQuery += " AND D1_SERIE   =  '"+SD1->D1_SERIE+"' "
            _cQuery += " AND D1_FORNECE =  '"+SD1->D1_FORNECE+"' "
            _cQuery += " AND D1_LOJA    =  '"+SD1->D1_LOJA+"' "
            _cQuery += " AND D1_COD     =  '"+_cServico+"' "
            _cQuery += " AND D1_OP      <>  '' "
            _cQuery += " AND D_E_L_E_T_   =  '' "

            If Select("_MT103EXC") <> 0
                _MT103EXC->(DbCloseArea())
            EndIf
            
            TcQuery _cQuery New Alias "_MT103EXC"

            While _MT103EXC->(!Eof())

                fExcServOP()

                fExcluiOP()
            
                _MT103EXC->(dbskip())
            Enddo

            If Select("_MT103EXC") <> 0
                _MT103EXC->(DbCloseArea())
            EndIf

        Else //Se for Cte verifico se teve apontamento
            DbSelectarea('SD3')
            If FieldPos("D3_XCHVNFE") > 0
           	    fExcCusCte()
            Endif 
			
		Endif

    Endif 

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fExcluiOP
Rotina para excluir Ordem Produção

@author     Dirlei@uxpert
@since      10/11/2022

@return     Nil, Nenhum
@type       function
/*/
//---------------------------------------------------------------------
Static Function fExcluiOP()

    Local aArea	:= GetArea()
    Local aOrdem := {}
    Local nModAux := nModulo

    dbSelectArea("SB1") 
    //SB1->(dbSetOrder(1)) // B1_FILIAL + B1_COD
    //Posiciona SB1 se necessário
    If alltrim(SB1->B1_COD) <> alltrim(cProdOp)
        dbselectarea('SB1')
        dbsetorder(1)
        dbseek(xfilial('SB1') + cProdOp )
    Endif 


    dbSelectArea("SC2") 
    SC2->(dbSetOrder(1)) // C2_FILIAL + C2_NUM + C2_ITEM + C2_SEQUEN
    SC2->(dbSeek(xFilial("SC2") + _MT103EXC->D1_OP))

    cOP     := SC2->C2_NUM
    cItem   := SC2->C2_ITEM
    cSequen := SC2->C2_SEQUEN
    nQtdeOP := SC2->C2_QUANT

    aOrdem := { {"C2_NUM"    ,cOP		    , Nil},;
                {"C2_ITEM"   ,cItem		    , Nil},;
                {"C2_SEQUEN" ,cSequen		, Nil},;
                {"C2_PRODUTO",cProdOp       , Nil},;
                {"C2_QUANT"  ,nQtdeOp       , Nil},;
                {"C2_DATPRI" ,dDataBase	    , Nil},;
                {"C2_DATPRF" ,dDataBase	    , Nil},;
                {"C2_EMISSAO",dDataBase	    , Nil},;
                {"C2_PRIOR"  ,"500"		    , Nil},;
                {"C2_LOCAL"  ,SC2->C2_LOCAL , Nil},;
                {"C2_UM"     ,SB1->B1_UM    , Nil},;
                {"C2_STATUS" ,"N"		    , Nil},;
                {"AUTEXPLODE","S"           , Nil},;
                {"C2_TPOP"   ,"F"		    , Nil} }

    nModulo := 4 // Estoque/Custos
    lMsErroAuto := .F.
    MSExecAuto({|x,y| MATA650(x,y)},aOrdem,5)

    If !lMsErroAuto
        MsgInfo("Ordem de Produção "+ cOP + cItem + cSequen +" excluída!","Ordem Produção")
    Else
        MostraErro()
    EndIf


RestArea(aArea)
nModulo := nModAux

Return Nil


//Agrega custo do Servico ao custo medio 
Static Function fExcServOP()

	Local _nOpc := 5
	Local _aSD3 := {}
    
    //Busca movimentos do produto de serviço
    _cQuery := " SELECT D3_FILIAL,D3_DOC,R_E_C_N_O_ as RECNO,D3_LOCAL,D3_COD,D3_QUANT,D3_UM,D3_TIPO,D3_TM,D3_CUSTO1,D3_CF,D3_GRUPO,D3_XOP,D3_DOC,D3_EMISSAO,D3_NUMSEQ "
    _cQuery += " FROM "+RetsqlName('SD3')+" (NOLOCK) "
    _cQuery += " WHERE "
    _cQuery += " D3_FILIAL   = '"+_MT103EXC->D1_FILIAL+"' "
    _cQuery += " AND D3_COD  = '"+_cServico+"' "
    _cQuery += " AND (D3_OP  = '"+_MT103EXC->D1_OP+"' OR D3_XOP = '"+_MT103EXC->D1_OP+"') "
    _cQuery += " AND D3_ESTORNO   <>  'S' "
    _cQuery += " AND D_E_L_E_T_   =  '' "

    If Select("FEXCSERVOP") <> 0
        FEXCSERVOP->(DbCloseArea())
    EndIf
        
    TcQuery _cQuery New Alias "FEXCSERVOP"

    
    While FEXCSERVOP->(!eof())
        _aSD3 := {}
        //Posiciona SB1 se necessário
        If alltrim(SB1->B1_COD) <> alltrim(_cServico)
            dbselectarea('SB1')
            dbsetorder(1)
            dbseek(xfilial('SB1') + _cServico )
        Endif 

        DbSelectarea('SD3')
        DbSetOrder(3)
        dbgoto(FEXCSERVOP->RECNO)

        //Exclui movimento para valorização o serviço
        /*_aSD3:={{"D3_FILIAL"     , xFilial("SD3")          ,NIL},;
                {"D3_LOCAL"      ,  FEXCSERVOP->D3_LOCAL   ,NIL},;
                {"D3_COD"        ,  FEXCSERVOP->D3_COD     ,NIL},;
                {"D3_QUANT"      ,  FEXCSERVOP->D3_QUANT   ,NIL},;
                {"D3_EMISSAO"    ,  stod(FEXCSERVOP->D3_EMISSAO) ,NIL},;
                {"D3_UM"         ,  FEXCSERVOP->D3_UM      ,NIL},;
                {"D3_TIPO"       ,  FEXCSERVOP->D3_TIPO    ,NIL},;
                {"D3_TM"         ,  FEXCSERVOP->D3_TM      ,NIL},;
                {"D3_CUSTO1"     ,  FEXCSERVOP->D3_CUSTO1  ,NIL},;  
                {"D3_CF"     	 ,  FEXCSERVOP->D3_CF      ,NIL},; 
                {"D3_GRUPO"    	 ,  FEXCSERVOP->D3_GRUPO   ,NIL},;  
                {"D3_XOP"  	 ,  FEXCSERVOP->D3_XOP ,NIL},;
                {"D3_DOC"        ,  FEXCSERVOP->D3_DOC     ,NIL}} */

                aadd(_aSD3,{"D3_TM",SD3->D3_TM,})	
				aadd(_aSD3,{"D3_COD",SD3->D3_COD,})	
				aadd(_aSD3,{"D3_UM",SD3->D3_UM,})			
				aadd(_aSD3,{"D3_LOCAL",SD3->D3_LOCAL,})	
				aadd(_aSD3,{"D3_QUANT",SD3->D3_QUANT,})	
				aadd(_aSD3,{"D3_EMISSAO",SD3->D3_EMISSAO,})					
				aadd(_aSD3,{"D3_NUMSEQ",SD3->D3_NUMSEQ,})    	// aqui deverá ser colocado o D3_NUMSEQ do registro que foi incluido e agora
				aadd(_aSD3,{"INDEX",3,})	
                
            lMsErroAuto := .F.
        MSExecAuto({|x,y| mata240(x,y)},_aSD3,_nOpc) 

        If lMsErroAuto    
            MostraErro()
        //Else    
        //    MsgInfo("Excluido custo do produto: "+FEXCSERVOP->D3_DOC  ,"Custo do Servico")
        EndIf'

        FEXCSERVOP->(dbskip())
    Enddo

    If Select("FEXCSERVOP") <> 0
        FEXCSERVOP->(DbCloseArea())
    EndIf


Return  


//função para Excluir o movimento de custo do servico do arla
User Function xfExcServ()

	Local _nOpc := 5
	Local _aSD3 := {}
    Local _cServico := '401138 '        
    
    //Busca movimentos do produto de serviço
    _cQuery := " SELECT D3_FILIAL,D3_DOC,R_E_C_N_O_ as RECNO,D3_LOCAL,D3_COD,D3_QUANT,D3_UM,D3_TIPO,D3_TM,D3_CUSTO1,D3_CF,D3_GRUPO,D3_XOP,D3_DOC,D3_EMISSAO,D3_NUMSEQ "
    _cQuery += " FROM "+RetsqlName('SD3')+" (NOLOCK) "
    _cQuery += " WHERE "
    _cQuery += " D3_FILIAL   = '"+xfilial('SD3')+"' "
    _cQuery += " AND D3_COD  = '"+_cServico+"' "
    _cQuery += " AND  D3_XOP <> ''
    _cQuery += " AND D3_ESTORNO   <>  'S' "
    _cQuery += " AND D_E_L_E_T_   =  '' "

    If Select("FEXCSERVOP") <> 0
        FEXCSERVOP->(DbCloseArea())
    EndIf
        
    TcQuery _cQuery New Alias "FEXCSERVOP"

    
    While FEXCSERVOP->(!eof())
        _aSD3 := {}
        //Posiciona SB1 se necessário
        If alltrim(SB1->B1_COD) <> alltrim(_cServico)
            dbselectarea('SB1')
            dbsetorder(1)
            dbseek(xfilial('SB1') + _cServico )
        Endif 

        DbSelectarea('SD3')
        DbSetOrder(3)
        dbgoto(FEXCSERVOP->RECNO)

            aadd(_aSD3,{"D3_TM",SD3->D3_TM,})	
		    aadd(_aSD3,{"D3_COD",SD3->D3_COD,})	
			aadd(_aSD3,{"D3_UM",SD3->D3_UM,})			
			aadd(_aSD3,{"D3_LOCAL",SD3->D3_LOCAL,})	
			aadd(_aSD3,{"D3_QUANT",SD3->D3_QUANT,})	
			aadd(_aSD3,{"D3_EMISSAO",SD3->D3_EMISSAO,})					
			aadd(_aSD3,{"D3_NUMSEQ",SD3->D3_NUMSEQ,})    	// aqui deverá ser colocado o D3_NUMSEQ do registro que foi incluido e agora
			aadd(_aSD3,{"INDEX",3,})	
                
            lMsErroAuto := .F.
        MSExecAuto({|x,y| mata240(x,y)},_aSD3,_nOpc) 

        If lMsErroAuto    
            MostraErro()
        //Else    
        //    MsgInfo("Excluido custo do produto: "+FEXCSERVOP->D3_DOC  ,"Custo do Servico")
        EndIf'

        FEXCSERVOP->(dbskip())
    Enddo

    If Select("FEXCSERVOP") <> 0
        FEXCSERVOP->(DbCloseArea())
    EndIf


Return  


//função para Excluir o movimento de custo do servico do arla
Static Function fExcCusCte()

	Local _nOpc   := 5
	Local _aSD3   := {}
    Local _cQuery := ""
   

    _cQuery := " SELECT D3_COD,R_E_C_N_O_ AS RECNO FROM "+RetsqlName('SD3')+"(NOLOCK) "
    _cQuery += " WHERE D3_FILIAL = '"+SF1->F1_FILIAL+"' AND D3_XCHVNFE = '"+SF1->F1_CHVNFE+ "' " 
    _cQuery += " AND D_E_L_E_T_ = '' AND D3_ESTORNO <> 'S' "

	//Se for um Cte de Remessa de Arla Crio o movimento para Agregar Custo
	If (Select("XCUSCTE") <> 0)
		DbSelectArea("XCUSCTE")
		DbCloseArea()
	Endif        

    TcQuery _cQuery New Alias "XCUSCTE"

    While XCUSCTE->(!eof())
        
        _aSD3 := {}
        //Posiciona SB1 se necessário
        If alltrim(SB1->B1_COD) <> alltrim(XCUSCTE->D3_COD)
            dbselectarea('SB1')
            dbsetorder(1)
            dbseek(xfilial('SB1') + XCUSCTE->D3_COD )
        Endif 

        DbSelectarea('SD3')
        DbSetOrder(3)
        dbgoto(XCUSCTE->RECNO)

        aadd(_aSD3,{"D3_TM",SD3->D3_TM,})	
		aadd(_aSD3,{"D3_COD",SD3->D3_COD,})	
		aadd(_aSD3,{"D3_UM",SD3->D3_UM,})			
		aadd(_aSD3,{"D3_LOCAL",SD3->D3_LOCAL,})	
		aadd(_aSD3,{"D3_QUANT",SD3->D3_QUANT,})	
		aadd(_aSD3,{"D3_EMISSAO",SD3->D3_EMISSAO,})					
		aadd(_aSD3,{"D3_NUMSEQ",SD3->D3_NUMSEQ,})    	// aqui deverá ser colocado o D3_NUMSEQ do registro que foi incluido e agora
		aadd(_aSD3,{"INDEX",3,})	
                
        lMsErroAuto := .F.
        MSExecAuto({|x,y| mata240(x,y)},_aSD3,_nOpc) 

        If lMsErroAuto    
            MostraErro()
        //Else    
        //    MsgInfo("Excluido custo do produto: "+FEXCSERVOP->D3_DOC  ,"Custo do Servico")
        EndIf'

        XCUSCTE->(dbskip())
    Enddo

    If Select("XCUSCTE") <> 0
        XCUSCTE->(DbCloseArea())
    EndIf

Return  

