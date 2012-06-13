      SUBROUTINE RSLIPA(NOMSD,NOPARA,NOMOBJ,JADD,NBVAL)
      IMPLICIT   NONE
      INCLUDE 'jeveux.h'
      INTEGER JADD,NBVAL,N1,J1
      CHARACTER*(*) NOMSD,NOPARA,NOMOBJ
C ----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF UTILITAI  DATE 13/06/2012   AUTEUR COURTOIS M.COURTOIS 
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

C   EXTRAIRE D'UNE SD_RESULTAT, LA LISTE DES VALEURS D'UN PARAMETRE
C   ET RECOPIER CES VALEURS DANS L'OBJET NOMOBJ DONT ON REND L'ADRESSE.
C ----------------------------------------------------------------------
C IN  : NOMSD  : NOM DE LA STRUCTURE "RESULTAT".
C IN  : NOPARA : NOM DU PARAMETRE ('INST','FREQ', ...)
C IN  : NOMOBJ : NOM DE L'OBJET JEVEUX A CREER (K24)
C OUT : JADD   : ADRESSE DE L'OBJET NOMOBJ
C OUT : NBVAL  : LONGUEUR DE L'OBJET NOMOBJ
C-----------------------------------------------------------------------
C REMARQUES :
C  - L'OBJET RETOURNE (NOMOBJ) CONTIENT LES VALEURS DU PARAMETRE DANS
C    L'ORDRE DES NUMEROS DE RANGEMENT.
C    IL EST "PARALLELE" A L'OBJET .ORDR :
C    DO K=1,LONUTI(.ORDR) :
C       IORDR=.ORDR(K)
C       NOMOBJ(K) == "RSADPA(NOPARA,IORDR)"
C  - CETTE ROUTINE NE FAIT PAS JEMARQ/JEDEMA POUR NE PAS
C    INVALIDER L'ADRESSE JEVEUX JADD
      INTEGER IBID,KK,JORDR,JPARA,I1,JTAVA,L1
      CHARACTER*8 K8B,TSCA
      CHARACTER*5 NOM1
      CHARACTER*24 NOMK24
      CHARACTER*16 NOMPAR
      CHARACTER*19 NOMS2
C ----------------------------------------------------------------------

      NOMS2 = NOMSD
      NOMPAR= NOPARA
      NOMK24 = NOMOBJ

      CALL JENONU(JEXNOM(NOMS2//'.NOVA',NOMPAR),I1)
      CALL ASSERT(I1.GT.0)
      CALL JEVEUO(JEXNUM(NOMS2//'.TAVA',I1),'L',JTAVA)
      NOM1 = ZK8(JTAVA-1+1)
      CALL JELIRA(NOMS2//NOM1,'TYPE',IBID,TSCA)
      IF (TSCA.EQ.'K') THEN
        CALL JELIRA(NOMS2//NOM1,'LTYP',L1,K8B)
        IF (L1.EQ.8) THEN
          TSCA='K8'
        ELSEIF (L1.EQ.16) THEN
          TSCA='K16'
        ELSEIF (L1.EQ.24) THEN
          TSCA='K24'
        ELSEIF (L1.EQ.32) THEN
          TSCA='K32'
        ELSEIF (L1.EQ.80) THEN
          TSCA='K80'
        ELSE
          CALL ASSERT(.FALSE.)
        ENDIF
      ENDIF

      CALL JEVEUO(NOMS2//'.ORDR','L',JORDR)
      CALL JELIRA(NOMS2//'.ORDR','LONUTI',N1,K8B)

      CALL WKVECT(NOMK24,'V V '//TSCA,N1,J1)

      DO 1 KK=1,N1
         CALL RSADPA(NOMS2,'L',1,NOMPAR,ZI(JORDR-1+KK),0,
     &               JPARA,K8B)
         IF (TSCA.EQ.'R') THEN
           ZR(J1-1+KK)=ZR(JPARA)
         ELSEIF (TSCA.EQ.'C') THEN
           ZC(J1-1+KK)=ZC(JPARA)
         ELSEIF (TSCA.EQ.'I') THEN
           ZI(J1-1+KK)=ZI(JPARA)
         ELSEIF (TSCA.EQ.'K8') THEN
           ZK8(J1-1+KK)=ZK8(JPARA)
         ELSEIF (TSCA.EQ.'K16') THEN
           ZK16(J1-1+KK)=ZK16(JPARA)
         ELSEIF (TSCA.EQ.'K24') THEN
           ZK24(J1-1+KK)=ZK24(JPARA)
         ELSEIF (TSCA.EQ.'K32') THEN
           ZK32(J1-1+KK)=ZK32(JPARA)
         ELSEIF (TSCA.EQ.'K80') THEN
           ZK80(J1-1+KK)=ZK80(JPARA)
         ELSE
           CALL ASSERT (.FALSE.)
         ENDIF
1     CONTINUE

C     -- pour eviter les effets de bord (,ibid,ibid):
      JADD=J1
      NBVAL=N1

      END
