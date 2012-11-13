      SUBROUTINE JXCOPY ( CLSINZ , NOMINZ,  CLSOUZ , NMOUTZ , NBEXT )
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF JEVEUX  DATE 13/11/2012   AUTEUR COURTOIS M.COURTOIS 
C RESPONSABLE LEFEBVRE J-P.LEFEBVRE
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
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C TOLE CRP_6
      IMPLICIT NONE
      INCLUDE 'jeveux_private.h'
      CHARACTER*(*) CLSINZ , NOMINZ,  CLSOUZ , NMOUTZ
      CHARACTER*1         CLASIN , CLASOU
      CHARACTER*8         NOMIN  , NOMOUT
C     ------------------------------------------------------------------
C     RECOPIE D'UNE BASE DE DONNEES APRES ELIMINATION DES
C     ENREGISTREMENTS DEVENUS INACCESSIBLES
C     ------------------------------------------------------------------
C IN  CLSINZ : NOM DE CLASSE ASSOCIEE EN ENTREE
C IN  NOMINZ : NOM DE LA BASE EN ENTREE
C IN  CLSOUZ : NOM DE CLASSE ASSOCIEE EN SORTIE
C IN  NMOUTZ : NOM DE LA BASE EN SORTIE
C OUT NBEXT  : NOMBRE D'"EXTENDS" UTILISES APRES RETASSAGE
C     ------------------------------------------------------------------
      INTEGER          LK1ZON , JK1ZON , LISZON , JISZON 
      COMMON /IZONJE/  LK1ZON , JK1ZON , LISZON , JISZON
C     ------------------------------------------------------------------
      INTEGER          LBIS , LOIS , LOLS , LOR8 , LOC8
      COMMON /IENVJE/  LBIS , LOIS , LOLS , LOR8 , LOC8
      INTEGER          ISTAT
      COMMON /ISTAJE/  ISTAT(4)
C     ------------------------------------------------------------------
C-----------------------------------------------------------------------
      INTEGER IADLOC ,IADYN ,IB ,ICI ,ICO ,IERR ,K 
      INTEGER LBLOC ,N ,NBEXT ,NBLOC ,NREP ,NUMEXT 
C-----------------------------------------------------------------------
      PARAMETER  ( N = 5 )
C
      INTEGER          NBLMAX    , NBLUTI    , LONGBL    ,
     &                 KITLEC    , KITECR    ,             KIADM    ,
     &                 IITLEC    , IITECR    , NITECR    , KMARQ
      COMMON /IFICJE/  NBLMAX(N) , NBLUTI(N) , LONGBL(N) ,
     &                 KITLEC(N) , KITECR(N) ,             KIADM(N) ,
     &                 IITLEC(N) , IITECR(N) , NITECR(N) , KMARQ(N)
      INTEGER          IDN    , IEXT    , NBENRG
      COMMON /IEXTJE/  IDN(N) , IEXT(N) , NBENRG(N)
      CHARACTER*2      DN2
      CHARACTER*5      CLASSE
      CHARACTER*8                  NOMFIC    , KSTOUT    , KSTINI
      COMMON /KFICJE/  CLASSE    , NOMFIC(N) , KSTOUT(N) , KSTINI(N) ,
     &                 DN2(N)
      INTEGER          NRHCOD    , NREMAX    , NREUTI
      COMMON /ICODJE/  NRHCOD(N) , NREMAX(N) , NREUTI(N)
      REAL *8          SVUSE,SMXUSE   
      COMMON /STATJE/  SVUSE,SMXUSE
      CHARACTER*128    REPGLO,REPVOL
      COMMON /BANVJE/  REPGLO,REPVOL
      INTEGER          LREPGL,LREPVO
      COMMON /BALVJE/  LREPGL,LREPVO  
C     ------------------------------------------------------------------
      CHARACTER*1      KCLAS
      CHARACTER*8      NOMBA1,NOMBA2,NOM
      CHARACTER*128    NOML1,NOML2
      INTEGER          ITP(1),JITP,IADITP,LGBL1,LGBL2,INFO,L1,L2
C DEB ------------------------------------------------------------------
      NOMIN  = NOMINZ
      CLASIN = CLSINZ
      NOMOUT = NMOUTZ
      CLASOU = CLSOUZ
C
      KCLAS = CLASIN
      CALL JEINIF ( 'POURSUITE' , 'DETRUIT', NOMIN , KCLAS, 1 , 1 , 1 )
      ICI = INDEX ( CLASSE , KCLAS)
      KCLAS = CLASOU
      NREP = NREMAX(ICI)
      NBLOC= NBENRG(ICI)
      LBLOC= LONGBL(ICI)
      NOM = NOMOUT(1:4)//'.?  '
      CALL LXMINS (NOM)
      IF ( NOM(1:4) .EQ. 'glob' ) THEN
        NOML1=REPGLO(1:LREPGL)//'/'//NOM
      ELSE IF ( NOM(1:4) .EQ. 'vola' ) THEN
        NOML1=REPVOL(1:LREPVO)//'/'//NOM
      ELSE
        NOML1='./'//NOM
      ENDIF
      INFO = 1
      CALL RMFILE (NOML1,INFO)
      CALL JEINIF ( 'DEBUT', 'SAUVE', NOMOUT, KCLAS, NREP, NBLOC, LBLOC)
      ICO = INDEX ( CLASSE , KCLAS)
      NOMBA1 = NOMFIC(ICI)(1:4)//'.   '
      NOMBA2 = NOMFIC(ICO)(1:4)//'.   '
C
      LGBL1= 1024*LONGBL(ICI)*LOIS
      LGBL2= 1024*LONGBL(ICO)*LOIS
      CALL JJALLS(LGBL1,0,' ','I',LOIS,'INIT',ITP,JITP,IADITP,IADYN)
      ISZON(JISZON+IADITP-1) = ISTAT(1)
      ISZON(JISZON+ISZON(JISZON+IADITP-4)-4) = ISTAT(4)
      SVUSE = SVUSE + (ISZON(JISZON+IADITP-4) - IADITP + 4) 
      SMXUSE = MAX(SMXUSE,SVUSE)
      DO 50  K=1,(NBLUTI(ICI)-1)/NBENRG(ICI)
        CALL JXOUVR(ICO,K+1)
        IEXT(ICO) = IEXT(ICO) + 1
 50   CONTINUE
C
      IF ( NOMBA1(1:4) .EQ. 'glob' ) THEN
        NOML1=REPGLO(1:LREPGL)//'/'//NOMBA1
        L1=LREPGL+1
      ELSE IF ( NOMBA1(1:4) .EQ. 'vola' ) THEN
        NOML1=REPVOL(1:LREPVO)//'/'//NOMBA1
        L1=LREPVO+1
      ELSE
        NOML1='./'//NOMBA1
        L1=2        
      ENDIF
      IF ( NOMBA2(1:4) .EQ. 'glob' ) THEN
        NOML2=REPGLO(1:LREPGL)//'/'//NOMBA2
        L2=LREPGL+1
      ELSE IF ( NOMBA2(1:4) .EQ. 'vola' ) THEN
        NOML2=REPVOL(1:LREPVO)//'/'//NOMBA2
        L2=LREPVO+1
      ELSE
        NOML2='./'//NOMBA2
        L2=2        
      ENDIF
      DO 100 K=1,NBLUTI(ICI)
        NUMEXT = (K-1)/NBENRG(ICI)
        IADLOC =  K - (NUMEXT*NBENRG(ICI))
        CALL CODENT(NUMEXT+1,'G',NOML1(L1+6:L1+7))
        CALL READDR (NOML1,ISZON(JISZON+IADITP),LGBL1,IADLOC,IERR)
        IF (IERR .NE. 0 ) THEN
          CALL U2MESS('F','JEVEUX_47')
        ENDIF
        CALL CODENT(NUMEXT+1,'G',NOML2(L2+6:L2+7))
        CALL WRITDR ( NOML2, ISZON(JISZON + IADITP),
     &                LGBL2, IADLOC, -1, IB, IERR )
        IF (IERR .NE. 0 ) THEN
          CALL U2MESS('F','JEVEUX_48')
        ENDIF
 100  CONTINUE
      NBEXT = NUMEXT+1
      CALL JXFERM (ICI)
      CALL JXFERM (ICO)
      CALL JJLIDY ( IADYN , IADITP )
      CLASSE(ICO:ICO) = ' '
      CLASSE(ICI:ICI) = ' '
      DO 300 K=1,NBEXT
        CALL CODENT(K,'G',NOML2(L2+6:L2+7))
        CALL CODENT(K,'G',NOML1(L1+6:L1+7))
        CALL CPFILE ('M',NOML2,NOML1)
 300  CONTINUE
C FIN ------------------------------------------------------------------
      END
