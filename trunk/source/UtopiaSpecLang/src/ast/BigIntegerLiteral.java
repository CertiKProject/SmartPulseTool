/*
 * Copyright (C) 2015 University of Freiburg
 * Copyright (C) 2013-2015 Vincent Langenfeld (langenfv@informatik.uni-freiburg.de)
 * 
 * This file is part of the ULTIMATE LTL2Aut plug-in.
 * 
 * The ULTIMATE LTL2Aut plug-in is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published
 * by the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * The ULTIMATE LTL2Aut plug-in is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public License
 * along with the ULTIMATE LTL2Aut plug-in. If not, see <http://www.gnu.org/licenses/>.
 * 
 * Additional permission under GNU GPL version 3 section 7:
 * If you modify the ULTIMATE LTL2Aut plug-in, or any covered work, by linking
 * or combining it with Eclipse RCP (or a modified version of Eclipse RCP), 
 * containing parts covered by the terms of the Eclipse Public License, the 
 * licensors of the ULTIMATE LTL2Aut plug-in grant you additional permission 
 * to convey the resulting work.
 */
package ast;

import java.math.BigInteger;

import de.uni_freiburg.informatik.ultimate.ltl2aut.ast.AstNode;

public class BigIntegerLiteral extends AstNode {
	
	BigInteger value;
	
	public BigIntegerLiteral(BigInteger value)
	{
		this.value = value;
	}
	
	@Override
	public String toString()
	{
		return value.toString();
	}

	public BigInteger getValue()
	{
		return value;
	}
}
