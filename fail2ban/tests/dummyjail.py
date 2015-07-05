# emacs: -*- mode: python; py-indent-offset: 4; indent-tabs-mode: t -*-
# vi: set ft=python sts=4 ts=4 sw=4 noet :

# This file is part of Fail2Ban.
#
# Fail2Ban is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# Fail2Ban is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Fail2Ban; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

# Fail2Ban developers

__copyright__ = "Copyright (c) 2012 Yaroslav Halchenko"
__license__ = "GPL"

from threading import Lock

from ..server.actions import Actions


class DummyJail(object):
	"""A simple 'jail' to suck in all the tickets generated by Filter's
	"""
	def __init__(self):
		self.lock = Lock()
		self.queue = []
		self.idle = False
		self.database = None
		self.actions = Actions(self)

	def __len__(self):
		try:
			self.lock.acquire()
			return len(self.queue)
		finally:
			self.lock.release()

	def putFailTicket(self, ticket):
		try:
			self.lock.acquire()
			self.queue.append(ticket)
		finally:
			self.lock.release()

	def getFailTicket(self):
		try:
			self.lock.acquire()
			try:
				return self.queue.pop()
			except IndexError:
				return False
		finally:
			self.lock.release()

	@property
	def name(self):
		return "DummyJail #%s with %d tickets" % (id(self), len(self))
