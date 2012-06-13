      SUBROUTINE LRMMNO ( FID, NOMAM2, NDIM, NBNOEU,
     &                    NOMU, NOMNOE, COORDO, COODSC, COOREF,
     &                    IFM, INFMED )
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
C RESPONSABLE SELLENET N.SELLENET
C-----------------------------------------------------------------------
C     LECTURE DU MAILLAGE -  FORMAT MED - LES NOEUDS
C     -    -     -                  -         --
C-----------------------------------------------------------------------
C     LECTURE DU FICHIER MAILLAGE AU FORMAT MED
C     ENTREES :
C       FID    : IDENTIFIANT DU FICHIER MED
C       NOMAM2 : NOM MED DU MAILLAGE A LIRE
C       NDIM   : DIMENSION DU PROBLEME (2  OU 3)
C       NBNOEU : NOMBRE DE NOEUDS DU MAILLAGE
C     SORTIES:
C-----------------------------------------------------------------------
C
      IMPLICIT NONE
C
C 0.1. ==> ARGUMENTS
C
      INCLUDE 'jeveux.h'
      INTEGER FID
      INTEGER NDIM, NBNOEU
      INTEGER IFM, INFMED
C
      CHARACTER*8 NOMU
      CHARACTER*24 COORDO, COODSC, COOREF
      CHARACTER*24 NOMNOE
      CHARACTER*(*)  NOMAM2
C
C 0.2. ==> COMMUNS
C
C
C 0.3. ==> VARIABLES LOCALES
C
      CHARACTER*6 NOMPRO
      PARAMETER ( NOMPRO = 'LRMMNO' )
C
      INTEGER EDNOEU
      PARAMETER (EDNOEU=3)
      INTEGER TYPNOE
      PARAMETER (TYPNOE=0)
      INTEGER EDFUIN
      PARAMETER (EDFUIN=0)
C
      INTEGER CODRET
      INTEGER IAUX
      INTEGER JCOORD, JCOORL
      INTEGER NTGEO
      INTEGER JCOODS, JCOORF
      INTEGER JNOMNO
C
      CHARACTER*4 DIMESP
      CHARACTER*15 SAUX15
      CHARACTER*8 SAUX08
      CHARACTER*64 NOMAMD
C
C     ------------------------------------------------------------------
      CALL JEMARQ ( )
C
      NOMAMD=NOMAM2
C
C====
C 1. LES NOMS DES NOEUDS
C====
C
      IF ( INFMED.GE.3 ) THEN
        WRITE (IFM,1001) NBNOEU
      ENDIF
 1001 FORMAT('LECTURE DES',I10,' NOEUDS',/)
C
C 1.1. ==> LECTURE DU NOM DANS LE FICHIER
C          SI LE FICHIER NE CONTIENT PAS DE NOMMAGE DES NOEUDS, ON LEUR
C          DONNE UN NOM PAR DEFAUT FORME AVEC LE PREFIXE 'N' SUIVI DE
C          LEUR NUMERO
C
      CALL WKVECT('&&'//NOMPRO//'.NOMNOE','V V K16',NBNOEU,JNOMNO)
      CALL MFNOML ( FID, NOMAMD, ZK16(JNOMNO),
     &              EDNOEU, TYPNOE, CODRET )
C
      IF ( CODRET.NE.0 ) THEN
         IF (NBNOEU .GE. 10000000) THEN
C        PLUS DE 10 MILLIONS DE NOEUDS, ON PASSE EN BASE 36
            DO 11 , IAUX = 1 , NBNOEU
               CALL CODLET(IAUX,'G',SAUX15)
               ZK16(JNOMNO+IAUX-1) = 'N'//SAUX15
   11       CONTINUE
         ELSE
C        MOINS DE 10 MILLIONS DE NOEUDS, ON RESTE EN BASE 10
            DO 12 , IAUX = 1 , NBNOEU
               CALL CODENT(IAUX,'G',SAUX15)
               ZK16(JNOMNO+IAUX-1) = 'N'//SAUX15
   12       CONTINUE
         ENDIF
         CODRET = 0
      ENDIF
C
C 1.2. ==> TRANSFERT DANS LA STRUCTURE GLOBALE
C
      CALL JECREO (NOMNOE,'G N K8')
      CALL JEECRA (NOMNOE,'NOMMAX',NBNOEU,' ')
      DO 13 , IAUX = 1 , NBNOEU
        CALL JECROC (JEXNOM(NOMNOE,ZK16(JNOMNO+IAUX-1)(1:8)))
   13 CONTINUE
C
C====
C 2. LES COORDONNEES DES NOEUDS
C====
C
C 2.1. ==> CREATION DU TABLEAU DES COORDONNEES
C    LA DIMENSION DU PROBLEME PHYSIQUE EST VARIABLE (1,2,3), MAIS
C    ASTER STOCKE TOUJOURS 3 COORDONNEES PAR NOEUDS.
C
      CALL WKVECT (COORDO,'G V R',NBNOEU*3,JCOORD)
      CALL CODENT (NDIM,'G',DIMESP)
      CALL JEECRA (COORDO,'DOCU',0,DIMESP)
C
C 2.1. ==> EN DIMENSION 3, ON LIT LE TABLEAU DES COORDONNEES
C
C    LE TABLEAU COORDO EST UTILISE AINSI : COORDO(NDIM,NBNOEU)
C    EN FORTRAN, CELA CORRESPOND AU STOCKAGE MEMOIRE SUIVANT :
C    COORDO(1,1), COORDO(2,1), COORDO(3,1), COORDO(1,2), COORDO(2,2),
C    COORDO(3,2), COORDO(1,3), ... , COORDO(1,NBNOEU), COORDO(2,NBNOEU),
C    COORDO(3,NBNOEU)
C    C'EST CE QUE MED APPELLE LE MODE ENTRELACE
C
      IF ( NDIM.EQ.3 ) THEN
C
      CALL MFCOOL ( FID, NOMAMD, ZR(JCOORD), EDFUIN, CODRET )
      IF ( CODRET.NE.0 ) THEN
        SAUX08='MFCOOL  '
        CALL U2MESG('F','DVP_97',1,SAUX08,1,CODRET,0,0.D0)
      ENDIF
C
C 2.2. ==> AUTRES DIMENSIONS : ON CREE UN TABLEAU COMPACT DANS LEQUEL
C          ON STOCKE LES COORDONNEES, NOEUD APRES NOEUD.
C          C'EST CE QUE MED APPELLE LE MODE ENTRELACE.
C
      ELSE
C
      CALL WKVECT ('&&'//NOMPRO//'.COORL','V V R',NBNOEU*NDIM,JCOORL)
C
      CALL MFCOOL ( FID, NOMAMD, ZR(JCOORL), EDFUIN, CODRET )
      IF ( CODRET.NE.0 ) THEN
        SAUX08='MFCOOL  '
        CALL U2MESG('F','DVP_97',1,SAUX08,1,CODRET,0,0.D0)
      ENDIF
C
      IF ( NDIM .EQ. 2 ) THEN
        DO 221 , IAUX = 0,NBNOEU-1
          ZR(JCOORD+3*IAUX)   = ZR(JCOORL+2*IAUX)
          ZR(JCOORD+3*IAUX+1) = ZR(JCOORL+2*IAUX+1)
          ZR(JCOORD+3*IAUX+2) = 0.D0
  221   CONTINUE
      ELSE
        DO 222 , IAUX = 0,NBNOEU-1
          ZR(JCOORD+3*IAUX)   = ZR(JCOORL+IAUX)
          ZR(JCOORD+3*IAUX+1) = 0.D0
          ZR(JCOORD+3*IAUX+2) = 0.D0
  222   CONTINUE
      ENDIF
C
      ENDIF
C
C 2.3. ==> OBJET DESCRIPTEUR DU CHAMP DES COORDONNEES DES NOEUDS
C -   RECUPERATION DU NUMERO IDENTIFIANT LE TYPE DE CHAM_NO GEOMETRIE
      CALL JENONU (JEXNOM('&CATA.GD.NOMGD','GEOM_R'),NTGEO)
      CALL WKVECT (COODSC,'G V I',3,JCOODS)
      CALL JEECRA (COODSC,'DOCU',0,'CHNO')
      ZI(JCOODS)   = NTGEO
      ZI(JCOODS+1) = -3
      ZI(JCOODS+2) = 14
C
C -   OBJET REFE COORDONNEES DES NOEUDS
      CALL WKVECT (COOREF,'G V K24',4,JCOORF)
      ZK24(JCOORF) = NOMU
C
C====
C 3. LA FIN
C====
C
      CALL JEDETC ('V','&&'//NOMPRO,1)
C
      CALL JEDEMA ( )
C
      END
