      SUBROUTINE ERMES2(INO,TYPEMA,TYPMAV,IREF1,IVOIS,ISIG,NBCMP,
     &                  DSG11,DSG22,DSG12)
      IMPLICIT NONE
      INTEGER INO,IREF1,IVOIS,ISIG,NBCMP
      REAL*8 DSG11(3),DSG22(3),DSG12(3)
      CHARACTER*8 TYPEMA,TYPMAV
C ----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 29/09/2009   AUTEUR GNICOLAS G.NICOLAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2006  EDF R&D                  WWW.CODE-ASTER.ORG
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
C ======================================================================
C  ERREUR EN MECANIQUE - TERME DE SAUT - DIMENSION 2
C  **        **                   *                *
C ======================================================================
C
C     BUT:
C         DEUXIEME TERME DE L'ESTIMATEUR D'ERREUR EN RESIDU EXPLICITE :
C         CALCUL DU SAUT DE CONTRAINTE ENTRE UN ELEMENT ET SON VOISIN.
C
C
C     ARGUMENTS:
C     ----------
C
C      ENTREE :
C-------------
C IN   INO      : NUMERO DE L'ARETE
C IN   TYPEMA   : TYPE DE LA MAILLE COURANTE
C               'QU4', 'QU8', 'QU9'
C               'TR3', 'TR6', 'TR7'
C IN   TYPMAV   : TYPE DE LA MAILLE VOISINE
C               'QUAD4', 'QUAD8', 'QUAD9'
C               'TRIA3', 'TRIA6', 'TRIA7'
C IN   IREF1    : ADRESSE DES CHARGEMENTS DE TYPE FORCE (CONTENANT AUSSI
C                 LES INFOS SUR LES VOISINS)
C IN   IVOIS    : ADRESSE DES VOISINS
C IN   ISIG     : ADRESSE DES CONTRAINTES AUX NOEUDS
C IN   NBCMP    : NOMBRE DE COMPOSANTES DU VECTEUR CONTRAINTE PAR NOEUD
C
C      SORTIE :
C-------------
C OUT  DSG11  :	SAUT DE CONTRAINTE AUX NOEUDS COMPOSANTE 11
C OUT  DSG22  :	SAUT DE CONTRAINTE AUX NOEUDS COMPOSANTE 22
C OUT  DSG12  :	SAUT DE CONTRAINTE AUX NOEUDS COMPOSANTE 12
C
C ......................................................................
C
C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------
C
      INTEGER        ZI
      COMMON /IVARJE/ZI(1)
      REAL*8         ZR
      COMMON /RVARJE/ZR(1)
      COMPLEX*16     ZC
      COMMON /CVARJE/ZC(1)
      LOGICAL        ZL
      COMMON /LVARJE/ZL(1)
      CHARACTER*8    ZK8
      CHARACTER*16          ZK16
      CHARACTER*24                  ZK24
      CHARACTER*32                          ZK32
      CHARACTER*80                                  ZK80
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C
C --------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ---------------------
C
      INTEGER IAREPE,JCELD,JCELV,IMAV,IGREL,IEL,IAVAL,ICONX1,ICONX2
      INTEGER JAD,JADV,NCHER,INDIIS
      INTEGER NBS,NBNA,NBSV,NBNV,I,JNO,MNO,INOV,JNOV,MNOV

      REAL*8 SIG11(3),SIG22(3),SIG12(3),SIGV11(3),SIGV22(3),SIGV12(3)

      CHARACTER*2 FORM,NOEU,FORMV,NOEUV
C
C ----------------------------------------------------------------------
C
C              X1          X2          X3
C               o-----------o-----------o
C              INO         MNO         JNO
C
C         POINTS  1 --> INO PREMIER POINT DE L'ARETE COURANTE
C                 2 --> JNO DEUXIEME POINT  DE L'ARETE COURANTE
C                 3 --> MNO NOEUD MILIEU S'IL EXISTE
C
C ----- RECHERCHE DES ADRESSES POUR OBTENIR SIGMA SUR LES VOISINS ------
C
      IAREPE=ZI(IREF1)
      JCELD=ZI(IREF1+1)
      JCELV=ZI(IREF1+2)
      IMAV=ZI(IVOIS+INO)
      IGREL=ZI(IAREPE+2*(IMAV-1))
      IEL=ZI(IAREPE+2*(IMAV-1)+1)
      IAVAL=JCELV-1+ZI(JCELD-1+ZI(JCELD-1+4+IGREL)+8)
C	
C ----- TESTS SUR LA MAILLE COURANTE -----------------------------------
C
      FORM=TYPEMA(1:2)
      NOEU=TYPEMA(3:3)
C
      IF (FORM.EQ.'TR') THEN
        NBS=3
        ELSE
        NBS=4
      ENDIF
      IF (NOEU.EQ.'3'.OR.NOEU.EQ.'4') THEN
        NBNA=2
        ELSE
        NBNA=3
      ENDIF
C
C ----- TESTS SUR LA MAILLE VOISINE ------------------------------------
C
      FORMV=TYPMAV(1:2)
      NOEUV=TYPMAV(5:5)
C
      IF (FORMV.EQ.'TR') THEN
        NBSV=3
        IF (NOEUV.EQ.'3') THEN
          NBNV=3
          ELSE IF (NOEUV.EQ.'6') THEN
          NBNV=6
          ELSE
          NBNV=7
        ENDIF
      ELSE IF (FORMV.EQ.'QU') THEN
        NBSV=4
        IF (NOEUV.EQ.'4') THEN
          NBNV=4
          ELSE IF (NOEUV.EQ.'8') THEN
          NBNV=8
          ELSE
          NBNV=9
        ENDIF
      ENDIF
C
C ----- CALCUL DE LA NUMEROTATION DU VOISIN ----------------------------
C
      IF (INO.EQ.NBS) THEN
        JNO=1
        ELSE
        JNO=INO+1
      ENDIF
C
      ICONX1=ZI(IREF1+10)
      ICONX2=ZI(IREF1+11)
      JAD=ICONX1-1+ZI(ICONX2+ZI(IVOIS)-1)
      JADV=ICONX1-1+ZI(ICONX2+ZI(IVOIS+INO)-1)
      NCHER=ZI(JAD-1+INO)
      INOV=INDIIS(ZI(JADV),NCHER,1,NBNV)
      NCHER=ZI(JAD-1+JNO)
      JNOV=INDIIS(ZI(JADV),NCHER,1,NBNV)
C
C ----- RECUPERATION DE SIGMA SUR LA MAILLE COURANTE ET LE VOISIN ------
C
      SIG11(1)=ZR(ISIG-1+NBCMP*(INO-1)+1)
      SIG22(1)=ZR(ISIG-1+NBCMP*(INO-1)+2)
      SIG12(1)=ZR(ISIG-1+NBCMP*(INO-1)+4)
C
      SIGV11(1)=ZR(IAVAL-1+NBCMP*NBNV*(IEL-1)+NBCMP*(INOV-1)+1)
      SIGV22(1)=ZR(IAVAL-1+NBCMP*NBNV*(IEL-1)+NBCMP*(INOV-1)+2)
      SIGV12(1)=ZR(IAVAL-1+NBCMP*NBNV*(IEL-1)+NBCMP*(INOV-1)+4)
C
      SIG11(2)=ZR(ISIG-1+NBCMP*(JNO-1)+1)
      SIG22(2)=ZR(ISIG-1+NBCMP*(JNO-1)+2)
      SIG12(2)=ZR(ISIG-1+NBCMP*(JNO-1)+4)
C
      SIGV11(2)=ZR(IAVAL-1+NBCMP*NBNV*(IEL-1)+NBCMP*(JNOV-1)+1)
      SIGV22(2)=ZR(IAVAL-1+NBCMP*NBNV*(IEL-1)+NBCMP*(JNOV-1)+2)
      SIGV12(2)=ZR(IAVAL-1+NBCMP*NBNV*(IEL-1)+NBCMP*(JNOV-1)+4)
C
      IF (NBNA.EQ.3) THEN
        MNO=NBS+INO
        MNOV=NBSV+JNOV
C
        SIG11(3)=ZR(ISIG-1+NBCMP*(MNO-1)+1)
        SIG22(3)=ZR(ISIG-1+NBCMP*(MNO-1)+2)
        SIG12(3)=ZR(ISIG-1+NBCMP*(MNO-1)+4)
C
        SIGV11(3)=ZR(IAVAL-1+NBCMP*NBNV*(IEL-1)+NBCMP*(MNOV-1)+1)
        SIGV22(3)=ZR(IAVAL-1+NBCMP*NBNV*(IEL-1)+NBCMP*(MNOV-1)+2)
        SIGV12(3)=ZR(IAVAL-1+NBCMP*NBNV*(IEL-1)+NBCMP*(MNOV-1)+4)
      ENDIF
C
C ----- CALCUL DES SAUTS DE CONTRAINTES --------------------------------
C
      DO 10 I=1,NBNA
        DSG11(I)=SIG11(I)-SIGV11(I)
        DSG22(I)=SIG22(I)-SIGV22(I)
        DSG12(I)=SIG12(I)-SIGV12(I)
 10   CONTINUE
C        
      END
