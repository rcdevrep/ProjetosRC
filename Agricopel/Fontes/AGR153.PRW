#include "rwmake.ch"    

User Function AGR153()  

//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//�����������������������������������������������������������������������

SetPrvt("CCADASTRO,AROTINA,")

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � AGR153   � Autor � Deco               � Data �     01/02/05���                                                             		
�������������������������������������������������������������������������͹��
���Descri��o � Cadastro de cheques extras                                 ���
�������������������������������������������������������������������������͹��
���Uso       � Espec�fico para Agricopel                                  ���
�������������������������������������������������������������������������͹��
���Arquivos  � SEF -> Cadastro de cheques                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

cCadastro := "Cadastro de Cheques Extras"

aRotina   := { { "Pesquisar"    ,"AxPesqui" , 0, 1},;
               { "Incluir"      ,'ExecBlock("AGR154",.F.,.F.)' , 0, 2} }
//               { "Visualizar"   ,'ExecBlock("AGRXXX",.F.,.F.)' , 0, 3},;
//               { "Alterar"      ,'ExecBlock("AGRXXX",.F.,.F.)' , 0, 4},;
//               { "Excluir"      ,'ExecBlock("AGRXXX",.F.,.F.)' , 0, 5} }

//���������������������������������������������������������������������Ŀ
//� No caso do ambiente DOS, desenha a tela padrao de fundo             �
//�����������������������������������������������������������������������

#IFNDEF WINDOWS
    ScreenDraw("SMT050", 3, 0, 0, 0)
    @3,1 Say cCadastro Color "B/W"
#ENDIF

dbSelectArea("SEF")
dbSetOrder(1)

mBrowse( 6,1,22,75,"SEF")

Return