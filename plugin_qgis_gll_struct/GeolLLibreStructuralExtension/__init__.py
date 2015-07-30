"""
/***************************************************************************
 GeolLLibreStructuralExtension
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
 This script initializes the plugin, making it known to QGIS.
"""
def name():
    return "GeolLLibre - structural extension"
def description():
    return "QGIS plugin allowing to map structural symbols"
def version():
    return "Version 0.1"
def icon():
    return "icon.png"
def qgisMinimumVersion():
    return "1.0"
def classFactory(iface):
    # load GeolLLibreStructuralExtension class from file GeolLLibreStructuralExtension
    from geolllibrestructuralextension import GeolLLibreStructuralExtension
    return GeolLLibreStructuralExtension(iface)
