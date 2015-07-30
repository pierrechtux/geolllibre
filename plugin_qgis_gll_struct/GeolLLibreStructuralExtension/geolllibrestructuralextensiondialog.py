"""
/***************************************************************************
 GeolLLibreStructuralExtensionDialog
                                 A QGIS plugin
 QGIS plugin allowing to map structural symbols
                             -------------------
        begin                : 2014-04-29
        copyright            : (C) 2014 by Pierre Chevalier
        email                : pierrechevaliergeol@free.fr
 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/
"""

from PyQt4 import QtCore, QtGui
from ui_geolllibrestructuralextension import Ui_GeolLLibreStructuralExtension
# create the dialog for zoom to point
class GeolLLibreStructuralExtensionDialog(QtGui.QDialog):
    def __init__(self):
        QtGui.QDialog.__init__(self)
        # Set up the user interface from Designer.
        self.ui = Ui_GeolLLibreStructuralExtension()
        self.ui.setupUi(self)
