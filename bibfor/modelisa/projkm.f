      SUBROUTINE PROJKM(NMABET,NBMABE,MAILLA,X3DCA,NOEBE,LNUMA,LICNX,
     &                  NUMAIL,NBCNX,CXMA,XYZMA,NORMAL,
     &                  ITRIA,XBAR,IPROJ,EXCENT)
      IMPLICIT NONE
C-----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 13/06/2012   AUTEUR COURTOIS M.COURTOIS 
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
C-----------------------------------------------------------------------
C  DESCRIPTION : TENTATIVE DE PROJECTION D'UN NOEUD CABLE SUR LES
C  -----------   MAILLES APPARTENANT A LA STRUCTURE BETON
C                APPELANT : PROJCA
C
C  IN     : NMABET : CHARACTER*24 ,
C                    OBJET CONTENANT LES MAILLES BETON
C  IN     : NBMABE : INTEGER , SCALAIRE
C                    NOMBRE DE MAILLE BETON
C  IN     : MAILLA : CHARACTER*8 , SCALAIRE
C                    NOM DU CONCEPT MAILLAGE ASSOCIE A L'ETUDE
C  IN     : X3DCA  : REAL*8 , VECTEUR DE DIMENSION 3
C                    COORDONNEES DU NOEUD CABLE CONSIDERE
C  IN     : NOEBE  : INTEGER , SCALAIRE
C                    NUMERO DU NOEUD BETON LE PLUS PROCHE DU NOEUD CABLE
C                    CONSIDERE
C  IN     : LNUMA  : CHARACTER*19 , SCALAIRE
C                    NOM D'UN VECTEUR D'ENTIERS POUR STOCKAGE DES
C                    NUMEROS DES MAILLES AUXQUELLES APPARTIENT LE
C                    NOEUD NOEBE
C                    DIMENSION REAJUSTEE EN SORTIE
C  IN     : LICNX  : CHARACTER*19 , SCALAIRE
C                    NOM D'UN VECTEUR D'ENTIERS POUR STOCKAGE DES RANGS
C                    DU NOEUD NOEBE DANS LES TABLES DE CONNECTIVITE DES
C                    MAILLES AUXQUELLES IL APPARTIENT
C                    DIMENSION REAJUSTEE EN SORTIE
C  OUT    : NUMAIL : INTEGER , SCALAIRE
C                    SI PROJECTION REUSSIE : NUMERO DE LA MAILLE SUR
C                    LAQUELLE EST REALISEE LA PROJECTION
C  OUT    : NBCNX  : INTEGER , SCALAIRE
C                    SI PROJECTION REUSSIE : NOMBRE DE NOEUDS DE LA
C                    MAILLE SUR LAQUELLE EST REALISEE LA PROJECTION
C  OUT    : CXMA   : INTEGER , VECTEUR DE DIMENSION AU PLUS NNOMAX
C                    SI PROJECTION REUSSIE : NUMEROS DES NOEUDS DE LA
C                    MAILLE SUR LAQUELLE EST REALISEE LA PROJECTION
C                    (TABLE DE CONNECTIVITE)
C  OUT    : XYZMA  : REAL*8 , TABLEAU DE DIMENSIONS (3,NNOMAX)
C                    SI PROJECTION REUSSIE : TABLEAU DES COORDONNEES
C                    DES NOEUDS DE LA MAILLE SUR LAQUELLE EST REALISEE
C                    LA PROJECTION
C  OUT    : NORMAL : REAL*8 , VECTEUR DE DIMENSION 3
C                    SI PROJECTION REUSSIE : COORDONNEES DANS LE REPERE
C                    GLOBAL DU VECTEUR NORMAL AU PLAN MOYEN DE LA MAILLE
C                    SUR LAQUELLE EST REALISEE LA PROJECTION
C  OUT    : ITRIA  : INTEGER , SCALAIRE
C                    SI PROJECTION REUSSIE : INDICATEUR DU SOUS-DOMAINE
C                    AUQUEL APPARTIENT LE POINT PROJETE :
C                    ITRIA = 1 : TRIANGLE 1-2-3
C                    ITRIA = 2 : TRIANGLE 3-4-1
C  OUT    : XBAR   : REAL*8 , VECTEUR DE DIMENSION 3
C                    SI PROJECTION REUSSIE : COORDONNEES BARYCENTRIQUES
C                    DU POINT PROJETE (BARYCENTRE DES SOMMETS DU
C                    TRIANGLE 1-2-3 OU 3-4-1)
C  OUT    : IPROJ  : INTEGER , SCALAIRE
C                    INDICE DE PROJECTION
C                    IPROJ = -1  PROJECTION NON REUSSIE
C                    IPROJ =  0  LE POINT PROJETE EST A L'INTERIEUR
C                                DE LA MAILLE
C                    IPROJ =  1X LE POINT PROJETE EST SUR UNE FRONTIERE
C                                DE LA MAILLE
C                    IPROJ =  2  LE POINT PROJETE COINCIDE AVEC UN DES
C                                NOEUDS DE LA MAILLE
C  OUT    : EXCENT : REAL*8 , SCALAIRE
C                    SI PROJECTION REUSSIE : EXCENTRICITE DU NOEUD
C                    CABLE PAR RAPPORT A LA MAILLE SUR LAQUELLE EST
C                    REALISEE LA PROJECTION
C
C-------------------   DECLARATION DES VARIABLES   ---------------------
C
C
C ARGUMENTS
C ---------
      INCLUDE 'jeveux.h'
      CHARACTER*8   MAILLA
      CHARACTER*19  LNUMA, LICNX
      INTEGER       NOEBE, NUMAIL, NBCNX, CXMA(*), ITRIA, IPROJ, NBMABE
      REAL*8        X3DCA(*), XYZMA(3,*), NORMAL(*), XBAR(*), EXCENT
      CHARACTER*24  NMABET
C
C VARIABLES LOCALES
C -----------------
      INTEGER       ICNX, IMAIL, INOMA, JCOOR, JCXMA, JLICNX, JLNUMA,
     &              JNUMAB, JTYMA, NBMAOK, NOE, NTYMA
      REAL*8        D, DMAX, DX, DY, DZ, EPSG, X3DP(3)
      CHARACTER*1   K1B
      CHARACTER*24  CONXMA, COORNO, TYMAMA
C
      REAL*8        R8PREM
C
C-------------------   DEBUT DU CODE EXECUTABLE    ---------------------
C
      CALL JEMARQ()
C
C%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
C 1   ACCES AUX OBJETS DU CONCEPT MAILLAGE
C%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
C
      CONXMA = MAILLA//'.CONNEX'
      COORNO = MAILLA//'.COORDO    .VALE'
      CALL JEVEUO(COORNO,'L',JCOOR)
      CALL JEVEUO(NMABET,'L',JNUMAB)
      TYMAMA = MAILLA//'.TYPMAIL'
      CALL JEVEUO(TYMAMA,'L',JTYMA)
C
C%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
C 2   TENTATIVE DE PROJECTION DU NOEUD CABLE CONSIDERE SUR LES MAILLES
C     APPARTENANT A LA STRUCTURE BETON
C%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
C
      EPSG = 1.0D+08 * R8PREM()
      NBMAOK = 0
C
C.... BOUCLE SUR LES MAILLES APPARTENANT A LA STRUCTURE BETON, POUR
C.... RETROUVER LE NOEUD BETON LE PLUS PROCHE DANS LES CONNECTIVITES
C
      DO 10 IMAIL = 1, NBMABE
         NUMAIL = ZI(JNUMAB+IMAIL-1)
         CALL JELIRA(JEXNUM(CONXMA,NUMAIL),'LONMAX',NBCNX,K1B)
         CALL JEVEUO(JEXNUM(CONXMA,NUMAIL),'L',JCXMA)
         DO 20 ICNX = 1, NBCNX
C
C.......... SI LE NOEUD BETON EST RETROUVE DANS LES CONNECTIVITES,
C.......... TEST DE PROJECTION DU NOEUD CABLE SUR LA MAILLE COURANTE
C
            IF ( ZI(JCXMA+ICNX-1).EQ.NOEBE ) THEN
C
C............. ON NOTE LE NUMERO DE LA MAILLE ET L'INDICE DU NOEUD
C............. NOEBE DANS LA TABLE DE CONNECTIVITE ASSOCIEE
C
               NBMAOK = NBMAOK + 1
               CALL JEECRA(LNUMA,'LONUTI',NBMAOK,' ')
               CALL JEVEUO(LNUMA,'E',JLNUMA)
               ZI(JLNUMA+NBMAOK-1) = NUMAIL
               CALL JELIBE(LNUMA)
               CALL JEECRA(LICNX,'LONUTI',NBMAOK,' ')
               CALL JEVEUO(LICNX,'E',JLICNX)
               ZI(JLICNX+NBMAOK-1) = ICNX
               CALL JELIBE(LICNX)
C
C............. RECUPERATION DES NUMEROS ET DES COORDONNEES DES NOEUDS
C............. DE LA MAILLE
C
               DO 30 INOMA = 1, NBCNX
                  NOE = ZI(JCXMA+INOMA-1)
                  CXMA(INOMA) = NOE
                  XYZMA(1,INOMA) = ZR(JCOOR+3*(NOE-1)  )
                  XYZMA(2,INOMA) = ZR(JCOOR+3*(NOE-1)+1)
                  XYZMA(3,INOMA) = ZR(JCOOR+3*(NOE-1)+2)
  30           CONTINUE
C
C............. RECUPERATION DE LA NORMALE AU PLAN DE LA MAILLE
C
               NTYMA = ZI(JTYMA+NUMAIL-1)
               CALL CANORM(XYZMA(1,1),NORMAL(1),3,NTYMA,1)
C
C............. EXCENTRICITE DU NOEUD DU CABLE ET COORDONNEES
C............. DU POINT PROJETE
C
               EXCENT = NORMAL(1)*(X3DCA(1)-XYZMA(1,1))
     &                + NORMAL(2)*(X3DCA(2)-XYZMA(2,1))
     &                + NORMAL(3)*(X3DCA(3)-XYZMA(3,1))
               DMAX = 0.0D0
               DO 40 INOMA = 1, NBCNX
                  DX = X3DCA(1) - XYZMA(1,INOMA)
                  DY = X3DCA(2) - XYZMA(2,INOMA)
                  DZ = X3DCA(3) - XYZMA(3,INOMA)
                  D = DBLE ( SQRT ( DX*DX + DY*DY + DZ*DZ ) )
                  IF ( D.GT.DMAX ) DMAX = D
  40           CONTINUE
               IF ( DMAX.EQ.0.0D0 ) DMAX = 1.0D0
               IF ( DBLE(ABS(EXCENT))/DMAX.LT.EPSG ) EXCENT = 0.0D0
               CALL DCOPY(3,X3DCA(1),1,X3DP(1),1)
               IF ( EXCENT.NE.0.0D0 ) THEN
                  CALL DAXPY(3,-EXCENT,NORMAL(1),1,X3DP(1),1)
                  IF ( EXCENT.LT.0.0D0 ) THEN
                     EXCENT = DBLE(ABS(EXCENT))
                     CALL DSCAL(3,-1.0D0,NORMAL(1),1)
                  ENDIF
               ENDIF
C
C............. TEST D'APPARTENANCE DU POINT PROJETE AU DOMAINE
C............. GEOMETRIQUE DEFINI PAR LA MAILLE
C
               CALL PROJTQ(NBCNX,XYZMA(1,1),ICNX,X3DP(1),
     &                     ITRIA,XBAR(1),IPROJ)
               IF ( IPROJ.GE.0 ) THEN
                  GO TO 9999
               ELSE
                  GO TO 10
               ENDIF
C
            ENDIF
  20     CONTINUE
  10  CONTINUE
C
9999  CONTINUE
      CALL JEDEMA()
C
C --- FIN DE PROJKM.
      END
