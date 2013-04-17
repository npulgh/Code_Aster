      SUBROUTINE NMCORT(SDCRIT,NRESI ,IRESI ,VRESI ,VRESID,
     &                  PLATIT,PLATRE,CONVOK)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 15/04/2013   AUTEUR ABBAS M.ABBAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2013  EDF R&D                  WWW.CODE-ASTER.ORG
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
C RESPONSABLE ABBAS M.ABBAS
C
      IMPLICIT     NONE
      INCLUDE 'jeveux.h'

      CHARACTER*19 SDCRIT
      INTEGER      IRESI,NRESI
      REAL*8       VRESI,VRESID
      LOGICAL      CONVOK
      INTEGER      PLATIT
      REAL*8       PLATRE
C
C ----------------------------------------------------------------------
C
C ROUTINE MECA_NON_LINE (ALGORITHME - CONVERGENCE)
C
C VERIFICATION DES CRITERES D'ARRET SUR RESIDU - OPTION PLATEAU
C
C ----------------------------------------------------------------------
C
C
C IN  SDCRIT : SYNTHESE DES RESULTATS DE CONVERGENCE POUR ARCHIVAGE
C IN  NRESI  : NOMBRE DE RESIDUS A EVALUER
C IN  IRESI  : NUMERO DU RESIDU A TESTER
C IN  VRESI  : NORME MAXI DU RESIDU A EVALUER
C IN  VRESID : DONNEE UTILISATEUR POUR CONVERGENCE
C IN  PLATIT : LONGUEUR MAXI DU PLATEAU
C IN  PLATRE : LARGEUR DU TUNNEL AUTOUR DU PLATEAU
C OUT CONVOK . .TRUE. SI CRITERE RESPECTE
C
C
C
C A RESORBER
      CALL ASSERT(.FALSE.)
      END
