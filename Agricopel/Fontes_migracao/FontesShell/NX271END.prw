#INCLUDE "PROTHEUS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

//User Function TK271END()
//����������������������������������������������������������������������������������������������������������������������������������������������������������Ŀ
//�04/12/2017 - MAX IVAN (Nexus) - Mudado o nome da Fun��o (PE) de M460QRY p/ NX460QRY, e criado esta chamada dentro do fonte original da Shell.             �
//������������������������������������������������������������������������������������������������������������������������������������������������������������
User Function NX271END

	dbSelectArea("SC5")
	U_AGX603(SC5->C5_NUM) //REVISA COMISSAO

Return()