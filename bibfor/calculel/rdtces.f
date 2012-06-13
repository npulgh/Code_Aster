      SUBROUTINE RDTCES(MA2,CORRM,CES1,BASE,CES2,CODRET)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF CALCULEL  DATE 13/06/2012   AUTEUR COURTOIS M.COURTOIS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2012  EDF R&D                  WWW.CODE-ASTER.ORG
C THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY  
C IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY  
C THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR     
C (AT YOUR OPTION) ANY LATER VERSION.                                   
C                                                                       
C THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT   
C WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF            
C MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU      
C GENERAL PUBLIC LICENSE FOR MORE DETAILS.                              
C                                                                       
C YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE     
C ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,         
C   1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.         
C ======================================================================
C RESPONSABLE PELLET J.PELLET
      IMPLICIT NONE
      INCLUDE 'jeveux.h'
      INTEGER CODRET
      CHARACTER*8 MA2
      CHARACTER*19 CES1,CES2
      CHARACTER*(*) CORRM
      CHARACTER*1 BASE
C ---------------------------------------------------------------------
C BUT: REDUIRE UN CHAM_ELEM_S SUR UN MAILLAGE REDUIT
C ---------------------------------------------------------------------
C ARGUMENTS:
C MA2    IN       K8  : MAILLAGE REDUIT
C CES1   IN/JXIN  K19 : CHAM_ELEM_S A REDUIRE
C CES2   IN/JXOUT K19 : CHAM_ELEM_S REDUIT
C BASE   IN       K1  : BASE DE CREATION POUR CES2Z : G/V/L
C CORRM  IN       K*  : NOM DE L'OBJET CONTENANT LA CORRESPONDANCE
C                       IMA_RE -> IMA

C-----------------------------------------------------------------------

C     ------------------------------------------------------------------
      INTEGER JCORRM,NBMA2,IRET,JNBPT,JNBSP,JNBCMP
      INTEGER JCE1K,JCE1D,JCE1V,JCE1L,JCE1C,IMA1,IMA2,NBPT,NBSP,IAD1
      INTEGER JCE2D,JCE2V,JCE2L,JCE2C
      INTEGER IBID,IPT,ISP,IAD2
      INTEGER NCMP,ICMP
      CHARACTER*1 KBID
      CHARACTER*8 NOMGD,TYPCES
      CHARACTER*3 TSCA
      LOGICAL ISVIDE
C     ------------------------------------------------------------------
      CALL JEMARQ()

      CALL ASSERT(CES2.NE.' ')
      CALL ASSERT(CES1.NE.CES2)
      CODRET=1


C     1- RECUPERATION D'INFORMATIONS DANS CES1 :
C     ------------------------------------------
      CALL JEVEUO(CES1//'.CESK','L',JCE1K)
      CALL JEVEUO(CES1//'.CESD','L',JCE1D)
      CALL JEVEUO(CES1//'.CESC','L',JCE1C)
      CALL JEVEUO(CES1//'.CESV','L',JCE1V)
      CALL JEVEUO(CES1//'.CESL','L',JCE1L)

      NOMGD=ZK8(JCE1K-1+2)
      TYPCES=ZK8(JCE1K-1+3)
      NCMP=ZI(JCE1D-1+2)

      CALL DISMOI('F','TYPE_SCA',NOMGD,'GRANDEUR',IBID,TSCA,IBID)


C     2- CREATION DE 3 OBJETS CONTENANT LES NOMBRES DE POINTS,
C         SOUS-POINTS ET CMPS POUR CHAQUE MAILLE :
C     -----------------------------------------------------------
      CALL DISMOI('F','NB_MA_MAILLA',MA2,'MAILLAGE',NBMA2,KBID,IRET)
      CALL JEVEUO(CORRM,'L',JCORRM)
      CALL WKVECT('&&CESRED.NBPT','V V I',NBMA2,JNBPT)
      CALL WKVECT('&&CESRED.NBSP','V V I',NBMA2,JNBSP)
      CALL WKVECT('&&CESRED.NBCMP','V V I',NBMA2,JNBCMP)
      ISVIDE=.TRUE.
      DO 10,IMA2=1,NBMA2
        IMA1=ZI(JCORRM-1+IMA2)
        ZI(JNBPT-1+IMA2)=ZI(JCE1D-1+5+4*(IMA1-1)+1)
        ZI(JNBSP-1+IMA2)=ZI(JCE1D-1+5+4*(IMA1-1)+2)
        ZI(JNBCMP-1+IMA2)=MIN(ZI(JCE1D-1+5+4*(IMA1-1)+3),NCMP)
        IF ( ZI(JNBPT-1+IMA2).NE.0.AND.ZI(JNBSP-1+IMA2).NE.0
     &       .AND.ZI(JNBCMP-1+IMA2).NE.0 ) THEN
          ISVIDE=.FALSE.
        ENDIF
   10 CONTINUE
      IF ( ISVIDE ) GOTO 60
      CODRET=0


C     3- CREATION DE CES2 :
C     ---------------------------------------
      CALL CESCRE(BASE,CES2,TYPCES,MA2,NOMGD,NCMP,ZK8(JCE1C),ZI(JNBPT),
     &            ZI(JNBSP),ZI(JNBCMP))
      CALL JEVEUO(CES2//'.CESD','L',JCE2D)
      CALL JEVEUO(CES2//'.CESC','L',JCE2C)
      CALL JEVEUO(CES2//'.CESV','E',JCE2V)
      CALL JEVEUO(CES2//'.CESL','E',JCE2L)



C     4- REMPLISSAGE DES OBJETS .CESL ET .CESV :
C     ------------------------------------------
      DO 50,ICMP=1,NCMP

        DO 40,IMA2=1,NBMA2
          IMA1=ZI(JCORRM-1+IMA2)
          NBPT=ZI(JCE2D-1+5+4*(IMA2-1)+1)
          NBSP=ZI(JCE2D-1+5+4*(IMA2-1)+2)
          DO 30,IPT=1,NBPT
            DO 20,ISP=1,NBSP
              CALL CESEXI('C',JCE1D,JCE1L,IMA1,IPT,ISP,ICMP,IAD1)
              CALL CESEXI('C',JCE2D,JCE2L,IMA2,IPT,ISP,ICMP,IAD2)
              CALL ASSERT(IAD2.LE.0)
              IF ((IAD1.LE.0) .OR. (IAD2.EQ.0))GOTO 20

C               -- RECOPIE DE LA VALEUR:
              ZL(JCE2L-1-IAD2)=.TRUE.
              IF (TSCA.EQ.'R') THEN
                ZR(JCE2V-1-IAD2)=ZR(JCE1V-1+IAD1)
              ELSEIF (TSCA.EQ.'C') THEN
                ZC(JCE2V-1-IAD2)=ZC(JCE1V-1+IAD1)
              ELSEIF (TSCA.EQ.'I') THEN
                ZI(JCE2V-1-IAD2)=ZI(JCE1V-1+IAD1)
              ELSEIF (TSCA.EQ.'L') THEN
                ZL(JCE2V-1-IAD2)=ZL(JCE1V-1+IAD1)
              ELSEIF (TSCA.EQ.'K8') THEN
                ZK8(JCE2V-1-IAD2)=ZK8(JCE1V-1+IAD1)
              ELSEIF (TSCA.EQ.'K16') THEN
                ZK16(JCE2V-1-IAD2)=ZK16(JCE1V-1+IAD1)
              ELSEIF (TSCA.EQ.'K24') THEN
                ZK24(JCE2V-1-IAD2)=ZK24(JCE1V-1+IAD1)
              ELSEIF (TSCA.EQ.'K32') THEN
                ZK32(JCE2V-1-IAD2)=ZK32(JCE1V-1+IAD1)
              ELSEIF (TSCA.EQ.'K80') THEN
                ZK80(JCE2V-1-IAD2)=ZK80(JCE1V-1+IAD1)
              ELSE
                CALL ASSERT(.FALSE.)
              ENDIF

   20       CONTINUE
   30     CONTINUE

   40   CONTINUE
   50 CONTINUE


C     5- MENAGE :
C     -----------
   60 CONTINUE
      CALL JEDETR('&&CESRED.NBPT')
      CALL JEDETR('&&CESRED.NBSP')
      CALL JEDETR('&&CESRED.NBCMP')



      CALL JEDEMA()
      END
