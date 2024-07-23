//#INCLUDE "MATA805.ch"
#INCLUDE "PROTHEUS.CH"
#DEFINE USADO CHR(0)+CHR(0)+CHR(1)
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "colors.ch"
//#INCLUDE "protheus.ch"





/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MA805Process� Autor � Rodrigo de A. Sartorio� Data �13/09/00���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Processa a inclusao de saldos por localizacao fisica no SBF���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA805                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function AGX467()
// Obtem numero sequencial do movimento
LOCAL cNumSeq:=ProxNum(),i
// Numero do Item do Movimento
Local cCounter	:= '0001'	//StrZero(0,TamSx3('DB_ITEM')[1])   


Private cPerg := "AGX467"
	
	
	aRegistros := {}
	AADD(aRegistros,{cPerg,"01","Produto ?","mv_ch1","C",15,0,0,"G","","mv_par01","","","","","","","","","","","","","","","SB1"}) 
	AADD(aRegistros,{cPerg,"02","Armazem ?","mv_ch2","C",02,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})  
	AADD(aRegistros,{cPerg,"03","Quantidade?","mv_ch3","N",9,0,0,"G","","mv_par03","","","","","","","","","","","","","","",""}) 
	AADD(aRegistros,{cPerg,"04","Endereco ?","mv_ch4","C",15,0,0,"G","","mv_par04","","","","","","","","","","","","","","","SBE"})  
	AADD(aRegistros,{cPerg,"05","Lote     ?","mv_ch5","C",15,0,0,"G","","mv_par05","","","","","","","","","","","","","","",""})  
	AADD(aRegistros,{cPerg,"06","Documento ?","mv_ch6","C",6,0,0,"G","","mv_par06","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"07","Serie     ?","mv_ch7","C",3,0,0,"G","","mv_par07","","","","","","","","","","","","","","",""})     
	AADD(aRegistros,{cPerg,"08","Tipo Movimento ?","mv_ch4","N",1,0,0,"C","","mv_par08","ENTRADA","","","SAIDA","","","","","","","","","","",""})  
 
	
	U_CriaPer(cPerg,aRegistros)  
	
    cTipoMov := ""         

	
	Pergunte(cPerg,.T.)
	
	If MsgYesNo("Deseja atualizar saldos gerenciais (SBF) ?" ,"Acerto Saldos SBF")
		cCounter := Soma1(cCounter)  
		
			
		dbSelectArea("SB1")
		dbSetOrder(1)
	    dbgoTop()
	    if !dbseek(xFilial("SB1")+mv_par01)
	      Alert("Aten��o! Produto n�o encontrado!")
	      return()
	    EndIf
	    
	    cContLot := ""
	    cContEnd := ""    
	    cLote    := ""
	   
	    cContLot := SB1->B1_RASTRO
	    cContEnd := SB1->B1_LOCALIZ    
	    cLote    := mv_par05   
	    

	    
	    
/*	    If cContLot == "L"    
			//Verifico se o produto possui lote informado
			
			cQuery := ""
			cQuery += "SELECT * "   
			cQuery += "FROM " + RETSQLNAME("SB8") + " "    
			cQuery += "WHERE D_E_L_E_T_ <> '*' "        
			cQuery += "  AND B8_FILIAL = '"  + xFilial("SB8") + "' " 
			cQuery += "  AND B8_LOCAL   = '"   + mv_par02 + "' "  
			cQuery += "  AND B8_PRODUTO = '"   + mv_par01 + "' "  
			cQuery += "  AND B8_LOTECTL = '"   + mv_par05 + "' "  
			
			
			If (Select("QRY") <> 0)
				dbSelectArea("QRY")
				dbCloseArea()
			Endif
		
			cQuery := ChangeQuery(cQuery)
			TCQuery cQuery NEW ALIAS "QRY"
			
		    cExisLot := "N"
			dbSelectArea("QRY")
			dbGoTop()
			While !Eof()   
			   cExisLot := "S"
			   QRY->(dbSkip())
			EndDo
		    if cExisLot == "N"  
		      Alert("Aten��o! Lote n�o cadastrado!")
		      Return()
		    EndIf   
		 else
		    cLote := ""
		 EndIf*/
		    
	    //Seleciono o tipo de movimento
	    If mv_par08 == 1
	       cTipoMov := "499" //entrada  
	    else 
	       cTipoMov := "999" //saida
	    EndIf        
	
		//��������������������������������������������������������������Ŀ
		//�Cria registro de movimentacao por Localizacao (SDB)           �
		//����������������������������������������������������������������  
			
			  
	
		CriaSDB(mv_par01,;	// Produto
				mv_par02,;	// Armazem
			    mv_par03,;	// Quantidade
				mv_par04,;	// Localizacao
				"",;	// Numero de Serie
				mv_par06,;		// Doc
				mv_par07,;		// Serie
				"",;			// Cliente / Fornecedor
				"",;			// Loja
				"",;			// Tipo NF
				"ACT",;			// Origem do Movimento
				dDataBase,;		// Data
				cLote,;	// Lote
				"",; // Sub-Lote
				cNumSeq,;		// Numero Sequencial
				cTipoMov,;			// Tipo do Movimento
				"M",;			// Tipo do Movimento (Distribuicao/Movimento)
				cCounter,;		// Item
				.F.,;			// Flag que indica se e' mov. estorno
				0,;				// Quantidade empenhado
				0)		// Quantidade segunda UM
		//��������������������������������������������������������������Ŀ
		//�Soma saldo em estoque por localizacao fisica (SBF)            �
		//����������������������������������������������������������������
		GravaSBF("SDB")
	    MsgInfo("Procedimento Realizado com Sucesso!")    
	 EndIf
Return()




