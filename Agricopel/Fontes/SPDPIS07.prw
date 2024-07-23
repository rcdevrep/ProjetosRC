#INCLUDE "PROTHEUS.CH" 
#INCLUDE "RWMAKE.CH"

User Function SPDPIS07()

    Local	cFilial		:=	PARAMIXB[1]	//FT_FILIAL
    Local	cTpMov		:=	PARAMIXB[2]	//FT_TIPOMOV
    Local	cSerie		:=	PARAMIXB[3]	//FT_SERIE
    Local	cDoc		:=	PARAMIXB[4]	//FT_NFISCAL
    Local	cClieFor	:=	PARAMIXB[5]	//FT_CLIEFOR
    Local	cLoja		:=	PARAMIXB[6]	//FT_LOJA
    Local	cItem		:=	PARAMIXB[7]	//FT_ITEM
    Local	cProd		:=	PARAMIXB[8]	//FT_PRODUTO	 	
    Local	cConta		:=	""
    

    dbSelectArea('SB1')
    SB1->(dbSetOrder(1))
    if SB1->(dbSeek(cFilial + cProd))

        cConta	:=	SB1->B1_CONTA

    endif
    
Return cConta

