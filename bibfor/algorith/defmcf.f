      SUBROUTINE DEFMCF(NBM,NBMP,LOCFL0,LOCFLC)
      IMPLICIT NONE
C-----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 16/05/2000   AUTEUR KXBADNG T.KESTENS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2001  EDF R&D                  WWW.CODE-ASTER.ORG
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
C DESCRIPTION : DEFINITION DU TABLEAU DES MODES COUPLES EN CHOC 
C -----------
C               APPELANT : MDITM2
C
C-------------------   DECLARATION DES VARIABLES   ---------------------
C
C ARGUMENTS
C ---------
      INTEGER  NBM, NBMP
      LOGICAL  LOCFL0(*), LOCFLC(*)
C
C VARIABLES LOCALES
C -----------------
      INTEGER  I, ICOMPT
C
C-------------------   DEBUT DU CODE EXECUTABLE    ---------------------
C
      ICOMPT = 0
C
      DO 10 I = 1, NBM
C
         IF ( LOCFL0(I)) THEN
            ICOMPT = ICOMPT + 1
            IF ( ICOMPT.GT.NBMP ) THEN
               LOCFLC(I) = .FALSE.
            ELSE
               LOCFLC(I) = .TRUE.
            ENDIF
         ELSE
            LOCFLC(I) = .FALSE.
         ENDIF
C
  10  CONTINUE
C
C --- FIN DE DEFMCF.
      END
