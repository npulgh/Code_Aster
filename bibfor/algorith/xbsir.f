      SUBROUTINE XBSIR(NDIM,NNOP,NFH,NFE,DDLC,DDLM,IGEOM,COMPOR,JPINTT,
     &                   CNSET,HEAVT,LONCH,BASLOC,SIGREF,NBSIG,
     &                   IDEPL,LSN,LST,IVECTU,JPMILT,NFISS,JFISNO)

       IMPLICIT NONE
      INCLUDE 'jeveux.h'
C
       INTEGER       NDIM,NNOP,NFH,NFE,DDLC,DDLM,IGEOM,NBSIG,IVECTU
       INTEGER       JFISNO,NFISS
       INTEGER       CNSET(4*32),HEAVT(*),LONCH(10),IDEPL,JPINTT,JPMILT
       REAL*8        BASLOC(*),SIGREF,LSN(NNOP),LST(NNOP)
       CHARACTER*16  COMPOR(4)
       

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 19/12/2012   AUTEUR PELLET J.PELLET 
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
C TOLE CRS_1404 CRP_21
C
C      BSIGMC  -- CALCUL DES FORCES INTERNES B*SIGMA AUX NOEUDS
C                 DE L'ELEMENT DUES AU CHAMP DE CONTRAINTES SIGMA
C                 DEFINI AUX POINTS D'INTEGRATION DANS LE CADRE DE
C                 LA M�THODE X-FEM
C
C IN  NDIM    : DIMENSION DE L'ESPACE
C IN  NNOP    : NOMBRE DE NOEUDS DE L'ELEMENT PARENT
C IN  NFH     : NOMBRE DE FONCTIONS HEAVYSIDE
C IN  NFE     : NOMBRE DE FONCTIONS SINGULI�RES D'ENRICHISSEMENT
C IN  DDLC    : NOMBRE DE DDLS DE CONTACT (PAR NOEUD)
C IN  DDLM    : NOMBRE DE DDL PAR NOEUD MILIEU
C IN  IGEOM   : COORDONEES DES NOEUDS
C IN  PINTT   : COORDONN�ES DES POINTS D'INTERSECTION
C IN  CNSET   : CONNECTIVITE DES SOUS-ELEMENTS
C IN  HEAVT   : VALEURS DE L'HEAVISIDE SUR LES SS-ELTS
C IN  LONCH   : LONGUEURS DES CHAMPS UTILIS�ES
C IN  BASLOC  : BASE LOCALE AU FOND DE FISSURE
C IN  SIGMA   : CONTRAINTES DE CAUCHY AUX POINTS DE GAUSS DES SOUS-�LTS
C IN  NBSIG   : NOMBRE DE CONTRAINTES ASSOCIE A L'ELEMENT
C IN  LSN     : VALEUR DE LA LEVEL SET NORMALE AUX NOEUDS PARENTS
C IN  LST     : VALEUR DE LA LEVEL SET TANGENTE AUX NOEUDS PARENTS
C IN  PMILT   : COORDONNEES DES POINTS MILIEUX
C IN  NFISS   : NOMBRE DE FISSURES "VUES" PAR L'�L�MENT
C IN  JFISNO  : POINTEUR DE CONNECTIVIT� FISSURE/HEAVISIDE

C OUT IVECTU  : ADRESSE DU VECTEUR BT.SIGMA
C
C     VARIABLES LOCALES
      REAL*8        HE(NFISS),COORSE(81)
      CHARACTER*8   ELREFP,ELRESE(6),FAMI(6)
      INTEGER       NSE,JTAB(2),NCOMP,IRET
      INTEGER       ISE,IN,INO,NPG,J,CODOPT
      INTEGER       IRESE,NNO,FISNO(NNOP,NFISS),IFISS,IG,IBID
      LOGICAL       ISELLI

      DATA          ELRESE /'SE2','TR3','TE4','SE3','TR6','TE4'/
      DATA          FAMI   /'BID','XINT','XINT','BID','XINT','XINT'/

C.========================= DEBUT DU CODE EXECUTABLE ==================
C

      CALL ELREF1(ELREFP)

C     NOMBRE DE COMPOSANTES DE PHEAVTO (DANS LE CATALOGUE)
      CALL TECACH('OOO','PHEAVTO',2,JTAB,IRET)
      NCOMP = JTAB(2)

C     SOUS-ELEMENT DE REFERENCE : RECUP DE NNO ET NPG
      IF (.NOT.ISELLI(ELREFP).AND. NDIM.LE.2) THEN
        IRESE=3
      ELSE
        IRESE=0
      ENDIF
      CALL ELREF5(ELRESE(NDIM+IRESE),FAMI(NDIM+IRESE),IBID,NNO,
     &            IBID,NPG,IBID,IBID,IBID,IBID,IBID,IBID)

C     RECUPERATION DE LA CONNECTIVIT� FISSURE - DDL HEAVISIDES
C     ATTENTION !!! FISNO PEUT ETRE SURDIMENTIONN�
      IF (NFISS.EQ.1) THEN
        DO 30 INO = 1, NNOP
          FISNO(INO,1) = 1
30      CONTINUE
      ELSE
        DO 10 IG = 1, NFH
C    ON REMPLIT JUSQU'A NFH <= NFISS
          DO 20 INO = 1, NNOP
            FISNO(INO,IG) = ZI(JFISNO-1+(INO-1)*NFH+IG)
20        CONTINUE
10      CONTINUE
      ENDIF

C     R�CUP�RATION DE LA SUBDIVISION DE L'�L�MENT EN NSE SOUS ELEMENT
      NSE=LONCH(1)

C       BOUCLE SUR LES NSE SOUS-ELEMENTS
      DO 110 ISE=1,NSE

C       BOUCLE SUR LES 4/3 SOMMETS DU SOUS-TETRA/TRIA
        DO 111 IN=1,NNO
          INO=CNSET(NNO*(ISE-1)+IN)
          DO 112 J=1,NDIM
            IF (INO.LT.1000) THEN
              COORSE(NDIM*(IN-1)+J)=ZR(IGEOM-1+NDIM*(INO-1)+J)
            ELSEIF (INO.GT.1000 .AND. INO.LT.2000) THEN
              COORSE(NDIM*(IN-1)+J)=ZR(JPINTT-1+NDIM*(INO-1000-1)+J)
            ELSEIF (INO.GT.2000 .AND. INO.LT.3000) THEN
              COORSE(NDIM*(IN-1)+J)=ZR(JPMILT-1+NDIM*(INO-2000-1)+J)
            ELSEIF (INO.GT.3000) THEN
              COORSE(NDIM*(IN-1)+J)=ZR(JPMILT-1+NDIM*(INO-3000-1)+J)
            ENDIF
 112      CONTINUE
 111    CONTINUE

C       FONCTION HEAVYSIDE CSTE POUR CHAQUE FISSURE SUR LE SS-ELT
        DO 113 IFISS = 1,NFISS
          HE(IFISS) = HEAVT(NCOMP*(IFISS-1)+ISE)
113     CONTINUE

        CODOPT=0
        IF (NDIM .EQ. 3) THEN

          CALL ASSERT(NBSIG.EQ.6)
          CALL XBSIG3(ELREFP,NDIM,COORSE,IGEOM,HE,
     &                NFH,DDLC,DDLM,NFE,BASLOC,NNOP,
     &                NPG,SIGREF,COMPOR,IDEPL,LSN,
     &                LST,NFISS,FISNO,
     &                CODOPT,IVECTU)

        ELSEIF (NDIM.EQ.2) THEN

          CALL ASSERT(NBSIG.EQ.4)
          CALL XBSIG2(ELREFP,ELRESE(NDIM+IRESE),NDIM,COORSE,IGEOM,HE,
     &                NFH,DDLC,DDLM,NFE,BASLOC,NNOP,
     &                NPG,SIGREF,COMPOR,IDEPL,
     &                LSN,LST,NFISS,FISNO,
     &                CODOPT,IVECTU)

        ENDIF

 110  CONTINUE


C.============================ FIN DE LA ROUTINE ======================

      END
